### vhb_qear20: 2020 VHB-ProDok Course Quantitative Empirical Accounting Research and Open Science Methods

### Welcome!

This is the repository of the upcoming VHB ProDok Course "Quantitative Empirical Accounting Research and Open Science Methods". We will use this repository to collaborate on the class project and to share class materials (slides, papers, etc.). Please keep in mind that this a _public_ repository, meaning that everybody can read its content. When you are new to Github I encourage you to take a look at the section ("Some guidance on git and Github") below prior to jumping at the content of the repo or the class project.

_If you are here and not a course member, feel free to browse around. Unfortunately, this course works with licensed data that you are most likely not able to access. You can, however, take a look at the code and the slides if you are interested._

### Class project

We will use this repository to collaborate on the class project that will explore German firms that currently file for insolvency. While the main purpose of the project is didactic in the sense that I want you to work on a data exercise to get familiar with a typical empirical workflow, I believe that it is also interesting to look at current insolvency cases from an economic standpoint. First, the corona crisis presents us with an extreme negative liquidity shock that varies predictably in the cross-section. Second, the German regulator has temporarily lifted the requirement for German firms to file for insolvency. Taken together, this provides us with a unique setting that, in the longer run, will provide some interesting quasi-experiments.

While the project B02 of TRR 266 will explore this setting in its research program, the objective of our class project is to document descriptively how firms that currently file for insolvency differ from the universe of German firms. For this, I provide you two datasets:

-	The first dataset (`insolvency_filings_de_julaug2020_incomplete.csv`, available in the `raw_data` directory) is a comma-separated value file and contains all filings recorded by the German insolvency courts in the months July and August. Data has been collected by weekly scraping of the official register (https://www.insolvenzbekanntmachungen.de). Obviously, it is currently still incomplete. After scraping the last filings in early September, I will replace it with a complete version. However, you should start working with the incomplete version (the final version will have the same format). I hope that the variable names of the data are self-explanatory. For further info on insolvencies in Germany, you can also refer to https://www.destatis.de/EN/Themes/Economic-Sectors-Enterprises/Enterprises/Business-Notifications-Insolvencies/_node.html.

-	The second dataset (`orbis_de.csv.gz`) is a gzipped comma separated value file containing firm-year accounting data for German firms. As it is commercially licensed, I will make it available for class members by other means. Store the unzipped file in the `raw_data` directory of your Github fork. Do not push this file to Github! To avoid that you accidentally commit the file, I included a local `.gitignore` file. Please keep in mind that the file contains commercially licensed data. For further information on the variables contained in the file, please refer to the documentation that you received via email. 

We will discuss things that we want to do with the data during our class sessions. To prepare for these sessions and to start familiarizing yourself with the data, I encourage each group to take a look at the two issues that I raised (button above). When you run into problems that you want to share/discuss with the whole group, reply to the issue in the main repository. Don't be shy. Asking questions is the best way to learn.

When writing code, please commit to the ```code``` directory of your group's fork. The code should generate clean data and/or samples for the analysis (to be stored in the ```data``` directory) and tables, figures, etc. (stored in the ```output``` directory). Content in these two directories should never be committed to the repository as it can and should be reproduced by running the code.

In terms of software, I have access to Stata, R, SAS, Python, LaTeX and the Office Suite of Microsoft (if need be). Feel free to pick the software that gets the job done for you but keep in mind that others need to be able to reproduce your work. While I am virtually certain that not all of us have access to STATA and/or SAS, everybody in principle has access to Python, R and RStudio since these packages are freely available.


### Group assignments

You will be working on the course assigments in groups. Each group should have (at lease) one independent 'fork' of this repository and work on this fork. As stated to the syllabus, group solutions to the two first issues are due by Sep 4. Only one solution per group please. Please try to make your solution as reproducible as possible, either by providing code or by adding a link to your Github fork that you used to produce the solution. Thanks!  


### Some guidance on git and Github

Quoting from happygitwithr.com: 

>"Git is s a version control system. Its original purpose was to help groups of developers work collaboratively on big software projects. Git manages the evolution of a set of files – called a repository – in a sane, highly structured way. If you have no idea what I’m talking about, think of it as the “Track Changes” features from Microsoft Word on steroids". 

A potential start is https://guides.github.com/activities/hello-world/ or http://kbroman.org/github_tutorial/. If you are interested in somewhat more detail and in how to link your R/RStudio environment to Github, try http://happygitwithr.com. If you are one of these youtube kids, you might try https://www.youtube.com/watch?v=E2d91v1Twcc. Don’t blame me if the video is boring or uninformative. I am not a youtube kid.


### Some guidance on R

While you are free to use any software from the list above, if you have no preferences, I would encourage you to take a look at R. There are many online references and tutorials around. A particularly useful textbook (which is available online) can be found here: http://r4ds.had.co.nz/.


### Disclaimer

<p align="center">
<img src="materials/programming_meme.jpg" alt="A meme!" width="40%"/>
</p>


