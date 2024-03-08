from flask import Flask, request, abort
from fastapi import HTTPException, WebSocketException
import hmac
import hashlib
import base64
#import sys
import subprocess


webhook = Flask(__name__)

#API_SECRET_KEY = 'my_webhook_api_secret'
# Run 'echo' and pipe the output to 'openssl'
echo_cmd = subprocess.Popen(["echo $CRYPT_SECRET"], shell=True, stdout=subprocess.PIPE)
print(echo_cmd.stdout)

# Run 'openssl' and pipe the output of 'echo' to it
#openssl_cmd = subprocess.Popen(["openssl", "enc", "-aes-256-ctr", "-pbkdf2", "-d", "-a", "-k", "oranges"], stdin=echo_cmd.stdout, stdout=subprocess.PIPE, encoding="utf-8")     
openssl_cmd = subprocess.check_output(["openssl", "enc", "-aes-256-ctr", "-pbkdf2", "-d", "-a", "-k", "oranges"], stdin=echo_cmd.stdout, encoding="utf-8")
#stdout, stderr = openssl_cmd.communicate()
#secret_token=str(stdout).strip()
secret_token=str(openssl_cmd).strip()
print("..")
print(secret_token)
print("...")

#def verify_webhook(data, hmac_header):
                # Calculate HMAC
#    digest = hmac.new(API_SECRET_KEY.encode('utf-8'), data, hashlib.sha256).digest()
#    computed_hmac = base64.b64encode(digest)

#    return hmac.compare_digest(computed_hmac, hmac_header.encode('utf-8'))


def verify_signature(payload_body, secret_token, signature_header):

    """Verify that the payload was sent from GitHub by validating SHA256.

    Raise and return 403 if not authorized.

    Args:
        payload_body: original request body to verify (request.body())
        secret_token: GitHub app webhook token (WEBHOOK_SECRET)
        signature_header: header received from GitHub (x-hub-signature-256)
    """
    if not signature_header:
        raise HTTPException(status_code=403, detail="x-hub-signature-256 header is missing!")
    hash_object = hmac.new(secret_token.encode('utf-8'), msg=payload_body, digestmod=hashlib.sha256)
    expected_signature = "sha256=" + hash_object.hexdigest()
#    if not hmac.compare_digest(expected_signature, signature_header):
#        raise HTTPException(status_code=403, detail="Request signatures didn't match!")
    return hmac.compare_digest(expected_signature, signature_header)

@webhook.route('/', methods=['POST'])
def handle_webhook():
                # Get raw body
    payload_body = request.get_data()
    #print("body")
    #print(payload_body)
                # Compare HMACs
    signature_header = request.headers.get('X-Hub-Signature-256')
    print("signature_header")
    print(signature_header)
    verified = verify_signature(payload_body, secret_token, signature_header)

    if not verified:
        print("not verified")
        abort(401)

# Do something with the webhook
    #subprocess.Popen(['git','pull'], stdout=subprocess.PIPE, cwd="/opt/mkdocs")
    git_pull_output = subprocess.check_output(['git', 'pull'], cwd="/opt/mkdocs")
    print("git pull output")
    print(git_pull_output)
    # deploy
    mkdocs_build_output = subprocess.check_output(['mkdocs', 'build'], cwd="/opt/mkdocs")
    print("mkdocs build output")
    print(mkdocs_build_output)

    print("verified")
    return ('', 200)

if __name__ == "__main__":
    from waitress import serve
    serve(webhook, host="0.0.0.0", port=8080)