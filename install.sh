set -o errexit  # abort on nonzero exitstatus
set -o nounset  # abort on unbound variable
set -o pipefail # don't hide errors within pipes

docker_args="-f docker-compose.yml"

function help() {
  echo "Usage:"
  echo "\t'install.sh' will run docker-compose with the default file\n"
  echo "Arguments:"
  echo "\t-f : provide a project name (see \`docker-compose.*.yml\` files)"
  echo "\t\tdocker-compose will run with the additional docker-compose.{file}.yml passed in argument"
  echo "\tUsage:"
  echo "\t\t'install.sh -f metabase -f project2' runs 'docker-compose -f docker-compose.yml -f docker-compose.metabase.yml -f docker-compose.project2.yml"
}

function build_docker_compose_args() {
  for file in $1; do
    docker_args+=" -f docker-compose.${file}.yml"
  done
}

while getopts :f:h flag; do
  case "${flag}" in
  f)
    build_docker_compose_args ${OPTARG}
    ;;
  h)
    help
    exit
    ;;
  \?) # Invalid option
    echo "Error: Invalid option"
    exit
    ;;
  esac
done

docker-compose -p koji $docker_args up -d
