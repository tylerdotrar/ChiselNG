#!/bin/bash
# Lazy script to compile both Windows & Linux binaries for chiselng
# 
# Package Requirements:
# --> golang-go
# --> mingw-w64
# --> musl-tools


## Create output directory
mkdir bin 2>/dev/null
echo "[+] Output directory: '$(pwd)/bin'"
echo ""


## Patch `main.go` w/ mainDelegate() function
# <will automate at a later time>
cd ../chisel


## Compile Windows DLL for C# embed and Go binary for testing
echo "[+] Compiling Windows binaries..." 
go env -w CC=x86_64-w64-mingw32-gcc
go env -w GOARCH=amd64
go env -w CGO_ENABLED=1
go env -w GOOS=windows

# 64-bit DLL
go build --buildmode=c-shared -ldflags="-s -w" -o ../helpers/bin/main64.dll .
echo " o  'main64.dll' compiled -- data type:"
file ../helpers/bin/main64.dll

# 32-bit DLL
go env -w CC=i686-w64-mingw32-gcc
go env -w GOARCH=386
go build --buildmode=c-shared -ldflags="-s -w" -o ../helpers/bin/main32.dll .
echo " o  'main32.dll' compiled -- data type:"
file ../helpers/bin/main32.dll

# 64-bit Executable (for testing)
go env -w CC=x86_64-w64-mingw32-gcc
go env -w GOARCH=amd64
go build -ldflags="-s -w" -o ../helpers/bin/chiselng_x64.exe .
echo " o  'chiselng_x64.exe' compiled -- data type:"
file ../helpers/bin/chiselng_x64.exe
echo " o  Done."
echo ""


## Compile standard Linux version
echo "[+] Compiling Linux binary..."
go env -w CC=musl-gcc # Use musl-gcc for easier static linking
go env -u GOOS        # Reset target OS back to Linux

# 64-bit Executable (Statically Linked)
go build -ldflags="-s -w -linkmode external -extldflags -static" -o ../helpers/bin/chiselng_amd64 .
echo " o  'chiselng_amd64' compiled -- data type:"
file ../helpers/bin/chiselng_amd64

# Broken: 32-bit Executable
#go env -w CC=i686-linux-musl-gcc
#go env -w GOARCH=386
#go build -ldflags="-s -w -linkmode external -extldflags -static" -o ../helpers/bin/chiselng_386 .
#file ../helpers/bin/chiselng_386
echo " o  Done."
echo ""


## Reset env
cd ../helpers
go env -u CC
go env -u GOOS
go env -u GOARCH
go env -u CGO_ENABLED

