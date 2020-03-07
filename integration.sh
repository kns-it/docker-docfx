#!/usr/bin/env bash

image_tag="${1:-latest}"

echo "Using image tag $image_tag"

if [ -d "./integration-test/" ];
then
    echo "Deleting existing integration test directory..."
    rm -rf ./integration-test/
fi

podman run --rm -ti -v `pwd`:/work:z -u root -w /work "knsit/docfx:$image_tag" init -o .integration-test/ --overwrite init -o .integration-test/ --overwrite
mkdir -p ./.integration-test/src/api/
dotnet new webapi -o ./.integration-test/src/api/ --force
cd ./.integration-test/
rm -rf **/obj/ **/bin/
podman run --rm -ti -v `pwd`:/work:z -u root -w /work "knsit/docfx:$image_tag" build 
podman run --rm -ti -v `pwd`:/work:z -u root -w /work "knsit/docfx:$image_tag" metadata 
podman run --rm -ti -v `pwd`:/work:z -u root -p 8080:8080 -w /work "knsit/docfx:$image_tag" docfx.json --serve --hostname "localhost"
