import json
import jwt  # PyJWT
import requests  # Para chamar o endpoint de refresh

# Configurações do JWT
JWT_SECRET = "3cfa76ef14937c1c0ea519f8fc057a80fcd04a7420f8e8bcd0a7567c272e007b"
JWT_ALGORITHM = "HS256"

# URL do endpoint de refresh (ajuste conforme o necessário)
AUTH_REFRESH_ENDPOINT = "https://p4520f6643.execute-api.us-east-1.amazonaws.com/refresh"

def refresh_token(cpf):
    """
    Chama o endpoint de refresh para obter um novo token.
    Esse endpoint espera apenas o CPF no corpo da requisição.
    """
    try:
        payload = {"cpf": cpf}
        response = requests.post(AUTH_REFRESH_ENDPOINT, json=payload, timeout=20)

        if response.status_code == 200:
            # Ajuste conforme o nome do campo que vem no JSON de resposta
            body = response.json()
            return body.get("token")
        else:
            print(f"Falha ao chamar refresh. Código HTTP: {response.status_code}")
            return None
    except requests.RequestException as e:
        print(f"Erro ao tentar renovar token: {e}")
        return None


def lambda_handler(event, context):
    """
    Lambda Authorizer para HTTP API (payload format = 2.0).
    Em 'Simple Response', retornamos somente:
      {
        "isAuthorized": True/False,
        "context": { ... }  # opcional
      }
    """

    print("Event recebido:", json.dumps(event))

    # Em HTTP API v2, o token costuma chegar em event["headers"]["authorization"]
    headers = event.get("headers", {})
    auth_header = headers.get("authorization", "")

    # Checa se começa com "Bearer "
    if not auth_header.startswith("Bearer "):
        return {"isAuthorized": False}

    # Extrai o token
    token = auth_header.split(" ", 1)[1]

    try:
        # Tenta decodificar o token (validação normal, incluindo exp)
        decoded_token = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        # Caso a decodificação seja bem sucedida, o token é válido e não expirou
        return {"isAuthorized": True}

    except jwt.ExpiredSignatureError:
        print("Token expirado, tentando renovar...")

        try:
            # Decodifica ignorando expiração, para extrair apenas o CPF
            partial_token = jwt.decode(
                token,
                JWT_SECRET,
                algorithms=[JWT_ALGORITHM],
                options={"verify_exp": False}  # ignora expiração para leitura do payload
            )
            # Aqui assumimos que o CPF está em sub
            cpf = partial_token.get("sub")

            if cpf:
                # Chama o endpoint de refresh para obter um novo token com base apenas no CPF
                new_token = refresh_token(cpf)
                if new_token:
                    try:
                        # Valida o novo token decodificando-o completamente
                        jwt.decode(new_token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
                        print("Token renovado com sucesso.")
                        return {"isAuthorized": True}
                    except jwt.InvalidTokenError:
                        print("Novo token recebido, porém inválido.")
            else:
                print("CPF não encontrado no token expirado (sub). Impossível renovar.")
        except jwt.InvalidTokenError:
            print("Token inválido ou corrompido. Não foi possível extrair CPF.")

        print("Falha ao renovar o token.")
        return {"isAuthorized": False}

    except jwt.InvalidTokenError:
        print("Token inválido.")
        return {"isAuthorized": False}
