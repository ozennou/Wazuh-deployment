from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium import webdriver
import os

def main():
    try:
        page = f'https://google.com/'
        # page = f'https://{os.getenv("DOCKER_SWARM_MASTER_IP")}/'
        path = "/usr/bin/chromedriver"
        # path = "C:\Users\a939950\Downloads\chromedriver_win32\chromedriver.exe"

        options = Options()
        options.add_argument('--headless=new')
        options.add_argument("--disable-dev-shm-usage")
        options.add_argument('--ignore-certificate-errors')
        options.add_argument('--allow-insecure-localhost')
        options.add_experimental_option('excludeSwitches', ['enable-logging'])
        options.add_argument("--log-level=3")
        options.add_argument("--silent")

        service = Service(executable_path=path)
        driver = webdriver.Chrome(service=service, options=options)

        driver.get(page)
    except Exception as e:
        print(f'Error: {e}')

if __name__ == "__main__":
    main()