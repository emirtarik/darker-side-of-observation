# The Darker Side of Observation

**Description**: This project analyzes the impact of social observation on prosocial behavior through a series of steps involving data cleaning, statistical modeling, and result visualization. ANR Project ANR-21-CE26-0022

## Table of Contents
1. [Introduction](#introduction)
2. [Requirements](#requirements)
3. [Setup](#setup)
4. [Usage](#usage)
5. [Files](#files)
6. [Results](#results)
7. [Authors](#authors)
8. [Acknowledgments](#acknowledgments)

## Introduction

Publicizing actions is a standard policy tool to promote prosocial behavior. This project shows that the efficacy of exposing individuals to social stigma crucially depends on whether the observers themselves faced the same moral dilemma before judging (active observers), a common feature in many environments. The study demonstrates that active observation polarizes evaluations: observers who acted prosocially judge more harshly selfish behavior and commend prosocial acts more highly. It also highlights that active observation decreases the quality of evaluations as observers ignore information to exploit moral wiggle room.

## Requirements

The following software and packages are required to run this project:

- Python 3.x
- Stata 15 or later
- Jupyter Notebook
- Required Python packages:
  - pandas
  - seaborn
  - matplotlib
  - nbformat
  - nbconvert
  - scikit-learn

## Setup

To set up the environment to run the project, follow these steps:

1. Clone the repository:
   
   ```
   git clone https://github.com/yourusername/darker-side-of-observation.git
   cd darker-side-of-observation
   ```

2. Install the required Python packages (this step can also be skipped as `master.py` automatically installs all requirements):
   
   ```
   pip install -r requirements.txt
   ```

3. Ensure Stata is installed and added to your system's PATH.

4. Adjust the directories in the `config.json` file as per your system configuration:

   ```
   {
     "main_path": "/path/to/your/main/directory",
     "data_path": "~/main/data/analysis",
     "code1_path": "~/main/code/01_clean",
     "code2_path": "~/main/code/02_analysis",
     "stata_path": "/Applications/Stata/StataMP.app/Contents/MacOS/StataMP" 
     /* stata_path is an example for MacOS using StataMP. 
     Could also be StataSP if the Standard Edition of Stata is used. */
   }
   ```

## Usage

To run the project, execute the `master.py` script which sequentially performs data cleaning, statistical modeling, and result visualization. Please refer to the `master.py` script for detailed steps.

```
   python master.py
```

## Files

- `master.py`: Main script to run the entire project workflow.
- `01_clean.do`: Stata script for cleaning the raw data.
- `02_methods.ipynb`: Jupyter Notebook for applying statistical methods and building models.
- `02_analysis.do`: Stata script for generating plots and tables used in the final analysis.
- `requirements.txt`: List of required Python packages.
- `config.json`: Configuration file specifying directory paths.

## Results

The findings suggest that active observation leads to more polarized evaluations compared to passive observation. Active observers who act prosocially judge selfish behavior more harshly and commend prosocial acts more highly.

## Authors

- Roberto Galbiati (Sciences Po and CNRS)
- Emeric Henry (Sciences Po and CEPR)
- Nicolas Jacquemet (Paris School of Economics and University Paris 1 Panthéon-Sorbonne)

## Acknowledgments

Revised version of CEPR Discussion Paper n°20355. We thank Constance Frohly, Emir Tarik Dakin, Laura Hespert and Th´eo Marquis for their research assistance, as well as Roland Bénabou, Francesco Bogliacino, Simon Gächter, Nobuyuki Hanaki, Itzhak Rasooly, Claudia Senik, Eugenio Verrina, Jo¨el van der Weele and participants to conferences and seminars at Sciences Po, Paris School of Economics, University of Osaka, the 2022 ASFEE annual conference (Lyon), the 2022 “Norms and Institutions” workshop (Konstanz), the 2022 “Social behaviour and discrimination” workshop (Paris), the 2023 AFSE annual conference (Paris) and the 2025 SEET conference (Dijon) for useful feedback and comments. The experiment was preregistered at the AEA RCT Registry: registry number AEARCTR-0011186. Financial support from the French National Research Agency (ANR-17-EURE-0001 and ANR-21-CE26-0022-02) is gratefully acknowledged.
