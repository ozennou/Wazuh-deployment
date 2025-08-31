import requests
import time
import os

def wait_for_server():
    url = f'https://{os.getenv("DOCKER_SWARM_MASTER_IP")}/'
    
    for i in range(30):
        try:
            response = requests.get(url, timeout=10, verify=False)
            print(f"Server is ready! Status: {response.status_code}")
            return True
        except:
            print(f"Attempt {i+1}/30: Server not ready, waiting...")
            time.sleep(10)
    
    print("Server not available after 5 minutes")
    return False

if __name__ == "__main__":
    wait_for_server()