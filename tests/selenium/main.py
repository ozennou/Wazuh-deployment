from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium import webdriver
import os
import time

def main():
    try:
        page = f'https://{os.getenv("DOCKER_SWARM_MASTER_IP")}/'
        path = "/usr/bin/chromedriver"

        options = Options()
        options.add_argument('--headless=new')
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-dev-shm-usage")
        options.add_argument('--ignore-certificate-errors')
        options.add_argument('--allow-insecure-localhost')
        options.add_experimental_option('excludeSwitches', ['enable-logging'])
        options.add_argument("--log-level=3")
        options.add_argument("--silent")

        service = Service(executable_path=path)
        driver = webdriver.Chrome(service=service, options=options)

        driver.get(page)

        driver.implicitly_wait(600)

        driver.find_element(By.XPATH, '//input[@placeholder="Username"]').send_keys(f'{os.getenv("DASHBOARD_USERNAME")}')
        driver.find_element(By.XPATH, '//input[@placeholder="Password"]').send_keys(f'{os.getenv("DASHBOARD_PASSWORD")}' + Keys.ENTER)

        elt = WebDriverWait(driver, 600).until(
            EC.presence_of_element_located((By.XPATH, "//span[@title='Last 24 hours alerts']"))
        )

        print("Successfully authenticate to Wazuh \nAll tests passed")

    except Exception as e:
        print(f'Error: {e}')
    finally:
        driver.close()
        driver.quit()

if __name__ == "__main__":
    main()