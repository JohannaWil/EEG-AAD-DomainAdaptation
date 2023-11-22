# Clarification of the structure in the data file "baselineData.mat".

The folder "Author" contains the results from MainBaseline.m which computes the baseline LOO-CV classification accuracy.
The data is saved in "baselineData.mat". 

To produce your own baseline results, change in MainBaseline.m to:
  "user = 'User';

The variable structure in "baselineData.mat":

  acc
  candSubs
  methodName
  refSubs
  taskName

# Variables
acc: LOO-CV classification accuracy for each subject in the DTU dataset. 

nSubjects = number of subjects
nTrials = 60, number of trials
nClasses = 2, number of classes in each task
p = 0.5, Level of chance in 2-classification problems

nTasks = number of classification tasks. Two different tasks are considered:

{1} Male/Female (MF): Attention to the male vs female voise

{2] Left/Right (LR): Attention to the left vs right side of the subject

The user defines which task to evaluate in MainBaseline.m and this decision is saved in the variable "taskName".

The user can choose between three different classificaton methods The decision is saved in the variable "methodName".
	SVM
	Decision Tree (Tree)
	k-nearest neighbor (k-NN)

Default (used in the article)
	task: Left/Right
	method: SVM

Based on the chosen task and method, the program saved the recommended reference and candidate subjects in:

  refSubs
  candSubs


Classification accuracy is computed with the inverse of the binomial cumulative distribution function (cdf):
	X = binoinv(0.95,nTrials,p)

y = 60: statistical significance level for nTrials and 2 classes

if acc is statistical significant:
	f = 0
else
	f = 1

# Summary acc structure:

	{1 x nSubjects}
		{1 x nTasks}
			MF: [AccSVM, ySVM, fSVM, AccTree, yTree, fTree, AcckNN, ykNN, fkNN]
			LF: [AccSVM, ySVM, fSVM, AccTree, yTree, fTree, AcckNN, ykNN, fkNN] 
