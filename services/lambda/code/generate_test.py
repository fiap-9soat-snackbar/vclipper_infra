import jwt
import datetime
import json

JWT_SECRET = "3cfa76ef14937c1c0ea519f8fc057a80fcd04a7420f8e8bcd0a7567c272e007b"
JWT_ALGORITHM = "HS256"

# Data/hora de expiração (ex.: 1 hora a partir de agora)
exp_time = datetime.datetime.utcnow()# + datetime.timedelta(hours=1)

# Monta o payload do JWT (sub = CPF)
payload = {
    "sub": "01234567890",
    "iat": datetime.datetime.utcnow(),
    "exp": exp_time
}

# Gera o token JWT
token = jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)

# 1) Formato v2 (HTTP API), simulando o event JSON
event_v2 = {
    "version": "2.0",
    "routeKey": "GET /endpoint-test",
    "rawPath": "/endpoint-test",
    "headers": {
        "authorization": f"Bearer {token}"
    },
    "requestContext": {
        "http": {
            "method": "GET",
            "path": "/teste"
        }
    }
}

# 2) Comando cURL para rodar no terminal
curl_command = f"""curl -i \\
  -X GET \\
  -H "Authorization: Bearer {token}" \\
  "https://lw461qp2r5.execute-api.us-east-1.amazonaws.com/dev/endpoint-test"
"""

# Imprime o cenário 1 (v2 event)
print("=== Cenário 1: JSON v2 Event (HTTP API) ===")
print(json.dumps(event_v2, indent=2))

# Imprime o cenário 2 (cURL command)
print("\n=== Cenário 2: Comando cURL ===")
print(curl_command)
print()
