
filename=$(basename -- "$1")
extension="${filename##*.}"
filename="${filename%.*}"


source="_episodes_rmd/${filename}.Rmd"
target="_episodes/${filename}.md"

if [ -f $source ] ; then
    Rscript -e "source('bin/generate_md_episodes.R')" $source $target
fi
