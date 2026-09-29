# ydev-alma95

AlmaLinux 9.5 をベースに、豊橋技術科学大学 HPC システムの窓口サーバ `ydev` に近い CLI 開発環境を再現するためのコンテナイメージです。

完全な `ydev` の複製ではなく、主にコンパイラ、言語処理系、基本的な開発ツールの再現を目的としています。

## Included environment

主な構成は以下の通りです。

- AlmaLinux 9.5
- GCC 11.5.0
- GCC Toolset 13 / GCC 13.3.1
- Python 3.12.5
- Perl 5.32
- Ruby 3.0.7
- OpenJDK 8
- Eigen 3.4.0
- Emacs 27.2
- Vim
- make / CMake / Autotools
- Git
- その他の基本的な CLI ツール

GCC Toolset 13 は次のように有効化できます。

```bash
source /opt/rh/gcc-toolset-13/enable
```

## Build locally

x86-64 Linux 用イメージとしてビルドします。

```bash
docker build \
  --platform linux/amd64 \
  -t ydev-alma95 .
```

または:

```bash
make build
```

動作確認:

```bash
make test
```

対話的に起動する場合:

```bash
docker run --rm -it \
  --platform linux/amd64 \
  ydev-alma95 \
  bash
```

## GitHub Container Registry

本リポジトリのイメージは、GitHub Container Registry (GHCR) で公開しています。

イメージ名:

```text
ghcr.io/ceekz/ydev-alma95:latest
```

## Singularity / TUT HPC

TUT HPC の Singularity 環境では、GHCR 上の OCI イメージを SIF に変換できます。

```bash
cd /work/$USER

mkdir -p tmp cache
export SINGULARITY_TMPDIR=/work/$USER/tmp
export SINGULARITY_CACHEDIR=/work/$USER/cache

singularity pull \
  ydev-alma95.sif \
  docker://ghcr.io/ceekz/ydev-alma95:latest
```

作成した SIF は `/work` 以下に保存して利用することを想定しています。

## Scope

このイメージには以下は含めていません。

- Intel oneAPI
- Intel MPI / OpenMPI
- AOCC / AOCL
- CUDA / ROCm
- MATLAB
- ABAQUS
- ANSYS
- COMSOL
- Gaussian
- GUI アプリケーション一式

HPC 固有ソフトウェアや商用ソフトウェアは、TUT HPC 側で提供される環境を利用することを想定しています。

AlmaLinux 9.5 のパッケージを再現可能にするため、パッケージ取得先は AlmaLinux 9.5 vault に固定しています。一部のパッケージは実際の `ydev` と patch level が異なる場合があります。現在の例では OpenJDK 8 の update level が該当します。

## References

- クラスタシステム構成 - TUT HPC Cluster Wiki  
  https://hpcportal.imc.tut.ac.jp/wiki/ClusterSystemSpec
- Singularityイメージファイルの入手 - TUT HPC Cluster Wiki  
  https://hpcportal.imc.tut.ac.jp/wiki/HowToRunNGCContainer
