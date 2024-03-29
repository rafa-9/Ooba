import time

import runpod
import requests
from requests.adapters import HTTPAdapter, Retry


automatic_session = requests.Session()
retries = Retry(total=10, backoff_factor=0.1, status_forcelist=[502, 503, 504])
automatic_session.mount('http://', HTTPAdapter(max_retries=retries))


# ---------------------------------------------------------------------------- #
#                              Automatic Functions                             #
# ---------------------------------------------------------------------------- #
def wait_for_service(url):
    '''
    Check if the service is ready to receive requests.
    '''
    while True:
        try:
            requests.get(url)
            return
        except requests.exceptions.RequestException:
            print("Service not ready yet. Retrying...")
        except Exception as err:
            print("Error: ", err)

        time.sleep(0.2)


def generate(inference_request):
    '''
    Run inference on a request.
    '''
    response = automatic_session.post(url='http://127.0.0.1:5000/api/v1/generate',
                                      json=inference_request, timeout=600)
    return response.json()

def chat(inference_request):
    '''
    Run inference on a request.
    '''
    response = automatic_session.post(url='http://127.0.0.1:5000/api/v1/chat',
                                      json=inference_request, timeout=600)
    return response.json()

def open_ai_completion(inference_request):
    '''
    Run inference on a request.
    '''
    response = automatic_session.post(url='http://127.0.0.1:5000/v1/completions',
                                      json=inference_request, timeout=600)
    return response.json()

def open_ai_chat(inference_request):
    '''
    Run inference on a request.
    '''
    response = automatic_session.post(url='http://127.0.0.1:5000/api/v1/chat/completions',
                                      json=inference_request, timeout=600)
    return response.json()

# ---------------------------------------------------------------------------- #
#                                RunPod Handler                                #
# ----- #
def handler(event):
    '''
    This is the handler function that will be called by the serverless.
    '''

    endpoint=event["input"]["api"]["endpoint"]
    payload=event["input"]["payload"]

    try:
        if endpoint == 'generate':
            response = generate(payload)
        elif endpoint == 'chat':
            response = chat(payload)
        elif endpoint == 'open_ai_completion':
            response = open_ai_completion(payload)
        elif endpoint == 'open_ai_chat':
            response = open_ai_chat(payload)
    except Exception as e:
        return {
            'error': str(e)
        }

    # return the output that you want to be returned like pre-signed URLs to output artifacts
    return response


if __name__ == "__main__":
    wait_for_service(url='http://127.0.0.1:5000/api/v1/model')

    print("Oobabooga API is ready. Starting RunPod...")
    runpod.serverless.start({"handler": handler})
