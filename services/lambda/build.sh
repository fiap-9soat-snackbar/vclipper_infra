#!/bin/bash
set -e

echo "Iniciando o build..."

# Remove qualquer build anterior
rm -rf build

# Cria a estrutura de diretórios dentro de build
mkdir -p build/layer/python
mkdir -p build/function

###############################
# 1) BUILD DA LAYER
###############################

# Instala as dependências usando o arquivo code/requirements.txt
pip install -r code/requirements.txt -t build/layer/python

echo "Conteúdo de build/layer/python após a instalação:"
find build/layer/python

# Empacota "build/layer" inteiro em "build/lambda_layer.zip"
echo "Gerando build/lambda_layer.zip com Python..."
python3 << 'EOF'
import os, zipfile

def zip_folder(folder, zip_filename):
    with zipfile.ZipFile(zip_filename, "w", zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, files in os.walk(folder):
            for file in files:
                full_path = os.path.join(root, file)
                # arcname = caminho relativo para que a pasta python fique na raiz do ZIP
                arcname = os.path.relpath(full_path, folder)
                zf.write(full_path, arcname)

zip_folder("build/layer", "build/lambda_layer.zip")
EOF
echo "build/lambda_layer.zip criado com sucesso."

###############################
# 2) BUILD DA FUNÇÃO LAMBDA
###############################

# Copiamos o authorizer.py para a pasta build/function para empacotar
cp code/authorizer.py build/function/

echo "Gerando build/authorizer.zip com Python..."
python3 << 'EOF'
import os, zipfile

def zip_folder(folder, zip_filename):
    with zipfile.ZipFile(zip_filename, "w", zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, files in os.walk(folder):
            for file in files:
                full_path = os.path.join(root, file)
                # arcname = caminho relativo para que o code fique na raiz do ZIP
                arcname = os.path.relpath(full_path, folder)
                zf.write(full_path, arcname)

zip_folder("build/function", "build/authorizer.zip")
EOF
echo "build/authorizer.zip criado com sucesso."

echo "Build finalizado: build/lambda_layer.zip e build/authorizer.zip gerados."
