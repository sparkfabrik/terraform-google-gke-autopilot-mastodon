.PHONY: lint tfscan generate-docs

lint:
	docker run --rm -v $${PWD}:/data -w /data --entrypoint sh ghcr.io/terraform-linters/tflint:v0.44.1 -c "tflint --init && tflint -f compact"

generate-docs:
	docker run --rm --volume "$$(pwd):/terraform-docs" -w /terraform-docs -u $$(id -u) quay.io/terraform-docs/terraform-docs:0.16.0 markdown table --config .terraform-docs.yml --output-file README.md --output-mode inject .

checkov:
	docker run -it -v "$$(pwd):/tf" --workdir /tf bridgecrew/checkov

