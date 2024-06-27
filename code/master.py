import json
import os
import subprocess
import threading
import itertools
import sys
import time

os.chdir(os.path.dirname(os.path.abspath(__file__)))

def install_dependencies():
    # Install dependencies from requirements.txt
    subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])

try:
    import nbformat
    from nbconvert.preprocessors import ExecutePreprocessor
    import seaborn as sns
    import pandas as pd
    import matplotlib.pyplot as plt
    from sklearn.neighbors import KNeighborsClassifier
    print("Perfect, you have all the necessary dependencies!")
except ImportError:
    print("Looks like you're missing some dependencies. Let's install them!")
    install_dependencies()
    print("Dependencies installed from requirements.txt and the script is running.")


import nbformat
from nbconvert.preprocessors import ExecutePreprocessor

def spinner():
    """Show a simple spinner/loading animation."""
    for c in itertools.cycle(['|', '/', '-', '\\']):
        if not running:
            break
        sys.stdout.write('\r' + c)
        sys.stdout.flush()
        time.sleep(0.1)
    sys.stdout.write('\rDone!     \n')


with open('config.json', 'r') as file:
    config = json.load(file)  


main_path = config['main_path']
data_path = config['data_path']
code1_path = config['code1_path']
code2_path = config['code2_path']
stata_path = config['stata_path']

def execute_notebook(notebook_path):
    print("Starting notebook execution...")
    start_time = time.time()

    # Load the notebook
    with open(notebook_path, 'r', encoding='utf-8') as f:
        nb = nbformat.read(f, as_version=4)

    # Execute the notebook
    ep = ExecutePreprocessor(timeout=600, kernel_name='python3')
    ep.preprocess(nb, {'metadata': {'path': '02_analysis'}})

    # Save the executed notebook
    #with open('executed_notebook.ipynb', 'w', encoding='utf-8') as f:
    #    nbformat.write(nb, f)

    end_time = time.time()
    print(f"Notebook executed in {end_time - start_time:.2f} seconds")

def run_stata_do_file(do_file_path):
    print("Starting Stata script execution... Click 'Ok' on the pop up window when Stata is done!")
    start_time = time.time()

    # Command to run Stata do file, adjust path to your Stata installation
    stata_command = [stata_path, "-b", "do", do_file_path]
    try:
        # Execute the command without shell=True
        result = subprocess.run(stata_command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print("Stata script executed successfully.")
        print(result.stdout.decode())  # Optionally print the output from Stata
    except subprocess.CalledProcessError as e:
        print("Error running Stata command:", e)
        print("Output:", e.stdout.decode())
        print("Errors:", e.stderr.decode())

    end_time = time.time()
    print(f"Stata script executed in {end_time - start_time:.2f} seconds")

def main():
    global running

    config_path = os.path.join(main_path, 'config.json')
    notebook_path = os.path.join(code2_path, '02_methods.ipynb')
    do_file_path1 = os.path.join(code1_path, '01_clean.do')
    do_file_path1 = '"' + do_file_path1 + '"'
    do_file_path2 = os.path.join(code2_path, '02_analysis.do')
    do_file_path2 = '"' + do_file_path2 + '"'

    running = True
    spinner_thread = threading.Thread(target=spinner)
    spinner_thread.start()
    time.sleep(0.1)

    try:
        # run 01_clean.do
        run_stata_do_file(do_file_path1)
        # run 02_methods.ipynb
        execute_notebook(notebook_path)
        # run 02_analysis.do
        run_stata_do_file(do_file_path2)
    finally:
        # Ensure the spinner stops after tasks are completed
        running = False
        spinner_thread.join()



if __name__ == "__main__":
    main()
