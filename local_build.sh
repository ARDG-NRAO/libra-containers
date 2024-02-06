#!/bin/bash
declare -A configs
configs=(
    ["volta70"]="Kokkos_ARCH_VOLTA70"
    ["turing75"]="Kokkos_ARCH_TURING75"
    ["ampere80"]="Kokkos_ARCH_AMPERE80"
    ["ampere86"]="Kokkos_ARCH_AMPERE86"
    ["hopper90"]="Kokkos_ARCH_HOPPER90"
)

export DOCKER_HUB_USERNAME=pjaganna
for tag in "${!configs[@]}"; do
    cuda_arch=${configs[$tag]}
    echo "Building with tag: $tag and CUDA architecture: $cuda_arch"
    podman build --build-arg Kokkos_CUDA_ARCH=$cuda_arch -t ${DOCKER_HUB_USERNAME}/libra:${tag} -f ./libra.dockerfile .
    podman push ${DOCKER_HUB_USERNAME}/libra:${tag}
done