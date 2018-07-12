#!/bin/bash

set -e

mkdir ../zf3
cd ../zf3

declare -a repos=(
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/companies-house.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-auth.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-autoload.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-backend.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-ci.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-common.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-config.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-devtools.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-elasticsearch.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-etl.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-internal.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-logging.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-oa.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-plugins.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-reporting.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-selfserve.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-static.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-templates.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-testhelpers.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-transfer.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-txc.git'
        'git@repo.shd.ci.nonprod.dvsa.aws:olcs/olcs-utils.git'
        )

for i in "${repos[@]}"
do
	git clone $i
done

git vol-each checkout -B feature/OLCS-20319-zf3-upgrade