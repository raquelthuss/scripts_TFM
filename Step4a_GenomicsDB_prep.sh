#!/bin/bash
#SBATCH --job-name=prep_gendb_Gs20
#SBATCH --output=prep_gendb_Gs20_%j.log
#SBATCH --error=prep_gendb_Gs20_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=02:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=raqthu@alum.us.es

set -euo pipefail

# ============================================================
# EDIT THESE
GM="Gs20"
CHUNK=10000000
# ============================================================

# Paths
# OUT_DIR se mantiene en una carpeta centralizada para GenomicsDB
OUT_DIR="../genomicsDB/genomicsdb_${GM}"
REFERENCE="../ref/glyso.PI483463.gnm1.YJWS.genome_main.fna"
CONTIG="glyso.PI483463.gnm1.${GM}"

SAMPLE_MAP="${OUT_DIR}/sample_map_${GM}.txt"
INTERVALS="${OUT_DIR}/${GM}_${CHUNK}.intervals.list"

mkdir -p "$OUT_DIR"

echo "============================================================"
echo "[INFO] PREP INPUTS"
echo "[INFO] GM         : $GM"
echo "[INFO] CONTIG     : $CONTIG"
echo "[INFO] BATCHES    : gvcf_batch_1 to 8"
echo "[INFO] OUT_DIR    : $OUT_DIR"
echo "[INFO] CHUNK      : $CHUNK"
echo "============================================================"

# -----------------------
# Build sample map (searching across all batches)
# -----------------------
echo "[INFO] Building sample map: $SAMPLE_MAP"

tmp_map="${SAMPLE_MAP}.tmp.$$"
: > "$tmp_map"

# Buscamos en cada uno de tus 8 directorios de batch
found_files=0
for i in {1..8}; do
    IN_DIR="../gvcf_batch_${i}"

    if [[ -d "$IN_DIR" ]]; then

        shopt -s nullglob

	list_tmp="list_batch${i}_$$.tmp"
	ls -1 "$IN_DIR" > "$list_tmp"

	if [[ -s "$list_tmp" ]]; then
	    while read -r fname; do
		# Patrón: nombre_cromosoma:inicio-fin.g.vcf.gz
		# Si el archivo es '143_glyso.PI483463.gnm1.Gs01:1-57896170.g.vcf.gz'
                # nos quedamos solo con 143
                sample=${fname%%_*}

		if [[ "$fname" == *"${CONTIG}"*".g.vcf.gz" ]]; then
		f="${IN_DIR}/${fname}"

		echo "[INFO] Checking: $fname"

			if [[ -f "${f}.tbi" ]]; then
        		abs_path="$(pwd)/$f"
			abs_path=$(echo "$abs_path" | sed 's#/\./#/#g; s#/[^/]*/\.\./#/#g')

	                 printf "%s\t%s\n" "$sample" "$abs_path" >> "$tmp_map"

	        	 ((found_files++)) || true
			else
			echo "[WARNING] No index .tbi found for $fname"
			fi
		fi
           done < "$list_tmp"
	   rm -f "$list_tmp"
	fi
   else
        echo "[WARNING] Batch directory not found: $IN_DIR"
    fi
done

[[ $found_files -gt 0 ]] || { echo "[ERROR] No .g.vcf.gz files found for $CONTIG in any batch directory"; exit 1; }

# Ordenar para reproducibilidad
sort -k1,1 "$tmp_map" > "${tmp_map}.sorted" && mv "${tmp_map}.sorted" "$tmp_map"

mv -f "$tmp_map" "$SAMPLE_MAP"
echo "[INFO] Total samples found and mapped: $(wc -l < "$SAMPLE_MAP")"

# Quick sanity: duplicates?
dups=$(cut -f1 "$SAMPLE_MAP" | sort | uniq -d | head -n 5 || true)
if [[ -n "$dups" ]]; then
  echo "[ERROR] Duplicate sample names found in sample_map (showing up to 5):"
  echo "$dups"
  exit 1
fi

# -----------------------
# Build intervals list
# -----------------------
echo "[INFO] Building intervals list: $INTERVALS"
[[ -f "${REFERENCE}.fai" ]] || { echo "[ERROR] Missing ${REFERENCE}.fai"; exit 1; }

LEN=$(awk -v c="$CONTIG" '$1==c{print $2}' "${REFERENCE}.fai" || true)
[[ -n "$LEN" ]] || { echo "[ERROR] Contig not found in .fai: $CONTIG"; exit 1; }

tmp_int="${INTERVALS}.tmp.$$"
python3 - <<PY > "$tmp_int"
chr="${CONTIG}"
L=int("${LEN}")
step=int("${CHUNK}")
for s in range(1, L+1, step):
    e=min(L, s+step-1)
    print(f"{chr}:{s}-{e}")
PY

mv -f "$tmp_int" "$INTERVALS"
echo "[INFO] Intervals in list: $(wc -l < "$INTERVALS")"

echo "[DONE] Prep complete."
echo "[DONE] sample_map: $SAMPLE_MAP"
echo "[DONE] intervals : $INTERVALS"
