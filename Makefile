S3_BUCKET_NAME = tzeyang.ng
deploy: 
	# Sync all files except for service-worker and index
	echo "Uploading cacheable files to $(S3_BUCKET_NAME)..."
	aws s3 sync src/ s3://$(S3_BUCKET_NAME)/ \
	--exclude *.js \
	--exclude *.html \
	--exclude *.css \
	--exclude .DS_Store \
	--delete

	echo "Uploading non-cacheable files"
	aws s3 sync src/ s3://$(S3_BUCKET_NAME)/ \
	--metadata-directive REPLACE \
	--cache-control max-age=0,no-cache,no-store,must-revalidate \
	--exclude "*" \
	--include *.js \
	--include *.html \
	--include *.css \
	--delete
