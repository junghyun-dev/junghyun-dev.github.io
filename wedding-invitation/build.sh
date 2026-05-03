#!/bin/bash
set -euo pipefail

echo "=== Wedding Invitation Build ==="
echo ""

# Clean and create build directory
rm -rf dist
mkdir -p dist

# Copy all source files to build directory
cp index.html dist/
cp admin.html dist/
# Copy photos directory if it exists (for future phases)
[ -d "photos" ] && cp -r photos dist/ || true

echo "Injecting secrets..."

# Account numbers (축의금)
sed -i "s|__ACCOUNT_GROOM_BANK__|${ACCOUNT_GROOM_BANK:-}|g" dist/index.html
sed -i "s|__ACCOUNT_GROOM_NUMBER__|${ACCOUNT_GROOM_NUMBER:-}|g" dist/index.html
sed -i "s|__ACCOUNT_BRIDE_BANK__|${ACCOUNT_BRIDE_BANK:-}|g" dist/index.html
sed -i "s|__ACCOUNT_BRIDE_NUMBER__|${ACCOUNT_BRIDE_NUMBER:-}|g" dist/index.html

# Groom's father account
sed -i "s|__ACCOUNT_GROOM_FATHER_BANK__|${ACCOUNT_GROOM_FATHER_BANK:-}|g" dist/index.html
sed -i "s|__ACCOUNT_GROOM_FATHER_NUMBER__|${ACCOUNT_GROOM_FATHER_NUMBER:-}|g" dist/index.html

# Bride's father account
sed -i "s|__ACCOUNT_BRIDE_FATHER_BANK__|${ACCOUNT_BRIDE_FATHER_BANK:-}|g" dist/index.html
sed -i "s|__ACCOUNT_BRIDE_FATHER_NUMBER__|${ACCOUNT_BRIDE_FATHER_NUMBER:-}|g" dist/index.html

# Groom's mother account
sed -i "s|__ACCOUNT_GROOM_MOTHER_BANK__|${ACCOUNT_GROOM_MOTHER_BANK:-}|g" dist/index.html
sed -i "s|__ACCOUNT_GROOM_MOTHER_NUMBER__|${ACCOUNT_GROOM_MOTHER_NUMBER:-}|g" dist/index.html

# Bride's mother account
sed -i "s|__ACCOUNT_BRIDE_MOTHER_BANK__|${ACCOUNT_BRIDE_MOTHER_BANK:-}|g" dist/index.html
sed -i "s|__ACCOUNT_BRIDE_MOTHER_NUMBER__|${ACCOUNT_BRIDE_MOTHER_NUMBER:-}|g" dist/index.html

# Naver Maps API key (Phase 3, but handle now)
sed -i "s|__NAVER_MAP_KEY__|${NAVER_MAP_KEY:-}|g" dist/index.html

# Bride & Groom names (process longer tokens before shorter to avoid partial match)
sed -i "s|__NAME_GROOM_EN__|${NAME_GROOM_EN:-}|g" dist/index.html
sed -i "s|__NAME_BRIDE_EN__|${NAME_BRIDE_EN:-}|g" dist/index.html
sed -i "s|__NAME_GROOM_FIRST_KO__|${NAME_GROOM_FIRST_KO:-}|g" dist/index.html
sed -i "s|__NAME_BRIDE_FIRST_KO__|${NAME_BRIDE_FIRST_KO:-}|g" dist/index.html
sed -i "s|__NAME_GROOM_FATHER_KO__|${NAME_GROOM_FATHER_KO:-}|g" dist/index.html
sed -i "s|__NAME_GROOM_MOTHER_KO__|${NAME_GROOM_MOTHER_KO:-}|g" dist/index.html
sed -i "s|__NAME_BRIDE_FATHER_KO__|${NAME_BRIDE_FATHER_KO:-}|g" dist/index.html
sed -i "s|__NAME_BRIDE_MOTHER_KO__|${NAME_BRIDE_MOTHER_KO:-}|g" dist/index.html
sed -i "s|__NAME_GROOM_KO__|${NAME_GROOM_KO:-}|g" dist/index.html
sed -i "s|__NAME_BRIDE_KO__|${NAME_BRIDE_KO:-}|g" dist/index.html

# Supabase (Phase 6)
sed -i "s|__SUPABASE_URL__|${SUPABASE_URL:-}|g" dist/index.html
sed -i "s|__SUPABASE_ANON_KEY__|${SUPABASE_ANON_KEY:-}|g" dist/index.html

# Admin page (Phase 7) — same Supabase tokens
sed -i "s|__SUPABASE_URL__|${SUPABASE_URL:-}|g" dist/admin.html
sed -i "s|__SUPABASE_ANON_KEY__|${SUPABASE_ANON_KEY:-}|g" dist/admin.html

echo ""
echo "Injecting gallery images..."

# Scan gallery-*.webp files sorted by filename (natural version sort)
GALLERY_IMGS=""
GALLERY_COUNT=0
for img in $(ls photos/gallery-*.webp 2>/dev/null | sort -V); do
  GALLERY_COUNT=$((GALLERY_COUNT + 1))
  FNAME=$(basename "$img")
  INDEX=$((GALLERY_COUNT - 1))
  GALLERY_IMGS="${GALLERY_IMGS}      <img class=\"gallery-grid__item\" src=\"photos/${FNAME}\" alt=\"갤러리 사진 ${GALLERY_COUNT}\" loading=\"lazy\" width=\"480\" height=\"480\" onclick=\"openLightbox(${INDEX})\">\n"
done

if [ "$GALLERY_COUNT" -eq 0 ]; then
  echo "WARNING: No gallery images found (photos/gallery-*.webp)"
  sed -i 's|<!-- __GALLERY_IMAGES__ -->||g' dist/index.html
else
  echo "Found ${GALLERY_COUNT} gallery images"
  # Use awk for multi-line replacement (sed struggles with newlines)
  awk -v imgs="$GALLERY_IMGS" '{gsub(/<!-- __GALLERY_IMAGES__ -->/, imgs); print}' dist/index.html > dist/index.html.tmp && mv dist/index.html.tmp dist/index.html
fi

echo ""
echo "Validating build..."

REMAINING=$(grep -oE '__[A-Z_]+__' dist/index.html dist/admin.html || true)
if [ -n "$REMAINING" ]; then
  echo "ERROR: Unreplaced placeholder tokens found in build output:"
  echo "$REMAINING" | sort -u
  echo ""
  echo "Ensure all required GitHub secrets are configured."
  exit 1
fi

echo "Build complete! No unreplaced tokens found."
echo "Output: dist/"
