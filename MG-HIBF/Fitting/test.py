import numpy as np
import pandas as pd



#===========================================================
#                   Read Excel File (Node_Property)
#===========================================================

file = pd.ExcelFile('Result-test.xlsx')
df1=pd.read_excel(file,'Node_Property')
data=df1[df1.columns[:]].to_numpy()
data = np.unique(data,axis=0)
#print ('data: \n',data)
Node_Name= data[:,0]
Memory= data[:,1]                                # Accessible memory size of CNk for running tasks
tsk= data[:,2]                                   # Switch time between two jobs for CNk 
#print(tsk)
#===========================================================
#                   Read Excel File 
#===========================================================

file = pd.ExcelFile('Result-test.xlsx')
df1=pd.read_excel(file,'General-Results')
data=df1[df1.columns[:]].to_numpy()
data = np.unique(data,axis=0)
#print ('data: \n',data)
nodename= data[:,0]
x= data[:,1]
y= data[:,2]


nodename_item =list(dict.fromkeys(nodename))
V = len(nodename_item)  # The number of nodes of the cluster

#===========================================================
#                   Read CSV File 
#===========================================================
genomes_df= pd.read_csv('overview-test.csv')

#===========================================================
#                   Initializing Variables
#===========================================================

#CNk=0                             # kth node of the cluster 
#Memk=0                            # Accessible memory size of
                                   # Switch time between two jobs for CNk
n=len(genomes_df.GenomeName)       # The number of genomes of the reference genome
Gen= genomes_df.GenomeName         # 
Gen= Gen[0:n]                      # The set of genomes of the reference genome
Si=genomes_df.Size                 # 
Si= Si[0:n]                        # Size of gi
J = n                              # The maximum number of Jobs 
poly1=[]
poly2=[]
poly3=[]
poly4=[]


Dictionary={}
FinalOutput={}
#===========================================================
#                   Initializing Genetic Algorithm parameters 
#===========================================================

solution =[]

population_number=20
MutationRate= 0.4
CrossoverRate= 1 - MutationRate
maxIter = 120
MutationNumber = round (population_number* MutationRate);
CrossoverNumber = round (population_number * CrossoverRate);


#================================================================================================
#                  f(X)= aX+b
#================================================================================================
           
def f1 (x, coefficient):
    t=(x*coefficient[0]+coefficient[1])
    return t


#================================================================================================
#                  f(X)= aX^2 + bX + c
#================================================================================================

def f2 (x, coefficient):
    t=(x**2*coefficient[0] +x*coefficient[1]+coefficient[2])
    return t



#================================================================================================
#                  f(X)= aX^3 + bX^2 + cX + d
#================================================================================================
def f3 (x, coefficient):
    t= x**3*coefficient[0] +x**2*coefficient[1] +x*coefficient[2]+coefficient[3]
    return t


#================================================================================================
#                  f(X)= aX^4 + bX^3+ cX^2 + dX + e
#================================================================================================
def f4 (x, coefficient):
    t=(x**4*coefficient[0] +x**3*coefficient[1] +x**2*coefficient[2] +x*coefficient[3]+coefficient[4])
    return t
#================================================================================================
#                  fk(X)
#================================================================================================
def fk (k,x, coefficients):
    if k==1:
        return f1(x, coefficients)
    if k==2:
         return f2(x, coefficients)
    if k==3:
         return f3(x, coefficients)
    if k==4:
         return f4(x, coefficients)


#================================================================================================
#                  Find The Best or Simplest Polynomaial Function Based on Mean Square Error 
#================================================================================================

Estimated_value_by_degree_1 =[]
Estimated_value_by_degree_2 =[]
Estimated_value_by_degree_3 =[]
Estimated_value_by_degree_4 =[]
MSE=[]
BestPloynomialDegree=[[]]
for i in range (V):
  MSE=[]
  #print('i : ', i)
  a= data ==nodename_item[i]
  nodenamep= nodename[a[:,0]]
  xp= x[a[:,0]]
  yp= y[a[:,0]]
  #print('Original X for node name of {} is: {}'.format(int(nodenamep[0]),xp))
  #print('Original Y for node name of {} is: {}'.format(int(nodenamep[0]),yp))
  #print('\n')

  #======================================================
  # Polynomaial Equation Degree of 1  & MSE 
  #======================================================
  coefficient1= np.polyfit(xp,yp,1);
  poly1.append(coefficient1)
  #print('coefficient1= ',coefficient1)
  Estimated_y_by_degree_1 = f1(xp,coefficient1);
  #print('Estimated Y by Degree of 1= ',  Estimated_y_by_degree_1)
  MSE.append(mean_squared_error(yp,Estimated_y_by_degree_1))


  #======================================================
  # Polynomaial Equation Degree of 2 & MSE
  #======================================================
  if (len(xp)>1):
      coefficient2= np.polyfit(xp,yp,2);
      poly2.append(coefficient2)
      #print('coefficient2= ',coefficient2)
      Estimated_y_by_degree_2=f2(xp,coefficient2);
      #print('Estimated Y by Degree of 2= ', Estimated_y_by_degree_2)
      MSE.append( mean_squared_error(yp,Estimated_y_by_degree_2))


  #======================================================
  # Polynomaial Equation Degree of 3 & MSE
  #======================================================
  if (len(xp)>2):
      coefficient3= np.polyfit(xp,yp,3)
      poly3.append(coefficient3)
      #print('coefficient3= ',coefficient3);
      Estimated_y_by_degree_3=f3(xp,coefficient3)
      #print('Estimated Y by Degree of 3= ',Estimated_y_by_degree_3 )
      MSE.append( mean_squared_error(yp,Estimated_y_by_degree_3))


  #======================================================
  # Polynomaial Equation Degree of 4 & MSE
  #======================================================
  if (len(xp)>3):
      coefficient4= np.polyfit(xp,yp,4)
      poly4.append(coefficient4);
      #print('coefficient4= ',coefficient4)
      Estimated_y_by_degree_4= f4(xp,coefficient4)
      #print('Estimated Y by Degree of 4= ',Estimated_y_by_degree_4)
      MSE.append( mean_squared_error(yp,Estimated_y_by_degree_4))


  #======================================================
  # Find Minimum of MSE and its index
  #======================================================
  #print('\n')
  #print ("MSE = ", MSE)
  MinMSE =min(MSE)
  #print("Min(MSE) = ", MinMSE)
  Dictionary={}
  Dictionary["NodeName"] = int( nodenamep[0])
  Dictionary["BestPloynomialDegree"]=MSE.index(MinMSE)+1
  if (MSE.index(MinMSE)==0):
      Dictionary["Coefficients"]=coefficient1
  elif (MSE.index(MinMSE)==1):
      Dictionary["Coefficients"]=coefficient2
  elif (MSE.index(MinMSE)==2):
      Dictionary["Coefficients"]=coefficient3
  elif (MSE.index(MinMSE)==3):
      Dictionary["Coefficients"]=coefficient4
        
  FinalOutput[i]= Dictionary
  BestPloynomialDegree.append([nodenamep[0],MSE.index(MinMSE)+1])

  #print('The Best and simplest Ploynomial Degree for node name {} is: {}'.format(int(nodenamep[0]),MSE.index(MinMSE)+1))
  #print('\n')
  #print ('*****************************************************************************************')
  #print('\n')
#======================================================
# Print result for Best Polynomaial Equation Degree Based MSE
#======================================================
#print('\n')
#print('==========================================================================================')
#print('           Best Ploynomial Degree (Based on MSE): \n', BestPloynomialDegree)
#print('==========================================================================================')
#print('\n')
#print('\n')
#print('\n')

FinalOutput




def jobs2cluster(S):
    AssignedJobs2Cluster={}
    for i in range (V):
        AssignedJobs2Cluster[i]=[]
    for j in range (n):
        Jobj=int(S[0][j])
        CNk=int(S[1][j])
        AssignedJobs2Cluster[CNk].append(Jobj)
    return (AssignedJobs2Cluster)

def genome2cluster(SS):
    g2c={}
    for i in range (V):
        g2c[i]=[]
    for j in range (n):
        Genomej=j
        CNk=int(SS[1][j])
        g2c[CNk].append(Genomej)
    return(g2c.copy())

"""Feasibility function for the Memk. Returns True if feasible False
    otherwise."""
def feasibleMemk(sol):
 
    
    M=np.zeros((V,J))

        
   
    for i in range (n):
        jobj= int(sol[0][i])
        CNk = int(sol[1][i])
        
        item= Si[i]
        q= len(item)
        if item[q-1]== 'K' or item[q-1]== 'k' :
            DigitSize=item[:-1]
            
            M[CNk][jobj]+= (float(DigitSize)/1000)
        elif  item[q-1]== 'M' or item[q-1]== 'm' :
            DigitSize=item[:-1]
            M[CNk][jobj]+= (float(DigitSize))
        
    for k in range (V):
        for j in range (J):
            if  Memory[k]< 3*M[k][j]:
                return False
    return True
    
  
  
def ComputeJobSize(g2j):
    sm=[]
    for j in range (J):
            sm.append(0.0)
    for j in range (J):
            GenomesNumber= g2j[j]
            m= len(GenomesNumber)
            
            #extract memory size of each genome belonged to Job j
            MemoryItems = (Si[GenomesNumber])
            
            for i in GenomesNumber:
                item= Si[i]
                q= len(item)
                if item[q-1]== 'K' or item[q-1]== 'k' :
                    DigitSize=item[:-1]
                    sm[j]+= float(DigitSize)/1000
                elif  item[q-1]== 'M' or item[q-1]== 'm' :
                    DigitSize=item[:-1]
                    sm[j]+= float(DigitSize)
    return sm.copy()

def RunningTime (Sl,g2cn):
    tk= np.zeros((V,1))
    J2C=jobs2cluster(Sl)
    G2J=Genomes2Jobs(Sl)
    JS= ComputeJobSize(G2J) # Job Size
    for k in range (V):
        NeedMemory=0
        for j in range (len(np.unique(J2C[k]))):
            #print ('Cluster Number is: {},  Job Number is {}, and Job size is {}. \n '.format (k,J2C[k][j],JS[J2C[k][j]]))
            NeedMemory=JS[J2C[k][j]]
            tk[k]+=fk(FinalOutput[k]['BestPloynomialDegree'],NeedMemory,FinalOutput[k]['Coefficients'])
    for i in range (V):
        GenomesNumber= g2cn[i]
        m= len(np.unique(J2C[i]))
        tk[i]+= ((m-1)*tsk[i])
        
    return max(tk)
            
 
          
        
    
def Genomes2Jobs(SL):
    Ge2Jo={}
    for i in range (n):
        Ge2Jo[i]=[]
    for j in range (n):
        Genomej=j
        Jobj=int(SL[0][j])
        Ge2Jo[Jobj].append(Genomej)
    return(Ge2Jo.copy())

def clusters2job(solu):
    C2Job={}
    for i in range (n):
        C2Job[i]=[]
    for j in range (n):
        Jobj=int(solu[0][j])
        CNk=int(solu[1][j])
        C2Job[Jobj].append(CNk)
      
    return(C2Job.copy())

import random
def AddressJobs2ClustersProblem(SOL):
    Temp= clusters2job(SOL.copy())
    t= len(Temp)
    for j in range (len(Temp)):
        if len(Temp[j])>1:
            newCNkIndex= random.randint(0,len(Temp[j])-1)
            newCNk= Temp[j][newCNkIndex]
            for i in range (n):
                if SOL[0][i]== j:
                    SOL[1][i]=newCNk
    return SOL.copy()
                
           
        
    
    
    
def equalSols(S1,S2):
    for j in range(len(S1)):
        if (S1[1][j]!= S2[1][j] or S1[0][j]!= S2[0][j] ):
                return False
    return True

def isRepeated(POp,Sol):
    index= False
    newPop=[]
    for i in range(len(POp)):
        newPop.append((POp[i].copy()))
    newPop=np.array(newPop.copy())
    N= len(POp)
    for i in range(N):
        if (equalSols(Sol.copy(),newPop[i,:,:].copy())):
                index =True
    return index


def arrangeSolutions(POPU):
    newFit = []
    newPop=np.empty((len(POPU), 2,n))
    for i in range(len(POPU)):
         if (feasibleMemk(POPU[i].copy())==True):
           
            newPop[i]=((POPU[i].copy()))
            SolvedSol= AddressJobs2ClustersProblem(POPU[i].copy())   
            G2CNK= genome2cluster(SolvedSol.copy())
            Fit= RunningTime(SolvedSol.copy(),G2CNK)
            newFit.append(Fit)
    
    return newPop.copy(),newFit.copy()
        
    
def AddNewSol(POPulation,Sol,FITS,Fit):
    index= isRepeated(POPulation.copy(),Sol.copy())
    L= len( POPulation.copy())
    if(index == False ):
        L=L+1
        POPulation= np.append(POPulation.copy(),Sol.copy())
        POPulation= POPulation.reshape(L,2,n)
        FITS.append(Fit)
        
    return POPulation.copy(),FITS.copy()

def SortPopulation(poP, FS,Npop):
    
    newFit = []    
    newPop=[]
    
    for i in range(len(poP)):
        newPop.append((poP[i].copy()))
        newFit.append(FS[i][0].copy())
    s = np.array(newFit.copy())
   
    sort_index = np.argsort(newFit.copy())
    for i in range(len(poP)):
        newPop[i]=list( poP[sort_index[i]].copy())
    FS.sort()
    
    return newPop.copy(),FS.copy(),len(newPop.copy())



def CreatePopulation (n):
    #population[i][j][k] ==> i th population 
    #[row0] ==> Job of solution [.......]
    #[row1] ==> CNk of solution [.......]
    Npop=1
    NS= np.zeros((2,n))
    for i in range (n):
            NS[0,i]=int(random.randint(0,J-1))# Random Job  number
            NS[1,i]=int(random.randint(0,V-1)) # Random Cluster Node number
    NS= AddressJobs2ClustersProblem(NS.copy())   
    Sol= genome2cluster(NS.copy())
        
    #JobSize = totalMemk(Sol)
    if (feasibleMemk(NS.copy())==True):
            POPULATION= np.empty((1, 2,n))
            for i in range(Npop):
                 POPULATION[0]= NS.copy()
            Fit= RunningTime(NS.copy(),Sol)
    else:
            while(feasibleMemk(NS.copy())==False):
                NS= np.zeros((2,n))
                for i in range (n):
                    NS[0,i]=int(random.randint(0,J-1))# Random Job  number
                    NS[1,i]=int(random.randint(0,V-1)) # Random Cluster Node number
                NS= AddressJobs2ClustersProblem(NS.copy())   

                Sol= genome2cluster(NS.copy())

                #JobSize = totalMemk(Sol)
                
                
                if (feasibleMemk(NS.copy())==True):
                    
                    POPULATION= np.empty((1, 2,n))
                    for j in range(n):
                        POPULATION[0]= NS.copy()
                    Fit= RunningTime(NS.copy(),Sol)
            
    return POPULATION.copy(),Fit.copy()
        
    
    
def Mutation(PP,FITS):   
    P=PP.copy()
    FF=FITS.copy()
    for iMut in range(MutationNumber):
            Npop= len(PP)
            SelectedSolutionIndex= random.randint(0,len(P)-1)
            SelectedSolution= (P[SelectedSolutionIndex]).copy()
            #print("SelectedSolution:\n", SelectedSolution)

            SelectedGenomeIndex1 = random.randint(0,n-1)
            SelectedGenomeIndex2 = random.randint(0,n-1)

            tempJ=SelectedSolution[0][SelectedGenomeIndex1]
            tempCNk=SelectedSolution[1][SelectedGenomeIndex1]
            SelectedSolution[0][SelectedGenomeIndex1]= SelectedSolution[0][SelectedGenomeIndex2].copy()
            SelectedSolution[1][SelectedGenomeIndex1]= SelectedSolution[1][SelectedGenomeIndex2].copy()
            SelectedSolution[0][SelectedGenomeIndex2]= tempJ
            SelectedSolution[1][SelectedGenomeIndex2]= tempCNk
            MutedSolution = AddressJobs2ClustersProblem(SelectedSolution.copy())
            Sol= genome2cluster(MutedSolution.copy())
            
           


            if (feasibleMemk(MutedSolution.copy())==True and  isRepeated(P.copy(),MutedSolution.copy()) ==False):
                #print('Mut len:',len(MutedSolution))
                F=( RunningTime(MutedSolution.copy(),Sol.copy()))
                P, FF= AddNewSol(P.copy(), MutedSolution.copy(),FITS.copy(),F) 
                if len(P)!= len(FF):
                    P,F= arrangeSolutions(P)
                    #print("Pop:\n", PP)
                    #print("!!!Mutelen(P):",len(P))
                    #print ("len Fit",len(F))
    return P, FF

def Crossover (POP,FITN):
    PoP=POP.copy()
    FiT=FITN.copy()
    for iCross in range(CrossoverNumber):
            Npop= len(PoP)
            SelectedSolutionIndex1= random.randint(0,len(PoP)-1)
            SelectedSolutionIndex2= random.randint(0,len(PoP)-1)

            SS1= PoP[SelectedSolutionIndex1].copy()
            SS2= PoP[SelectedSolutionIndex2].copy()

            SelectedGenomeIndex = random.randint(0,n-1)
            temp=  SS2[SelectedGenomeIndex:n-1].copy()
            SS2[SelectedGenomeIndex:n-1]= SS1[SelectedGenomeIndex:n-1].copy()
            SS1[SelectedGenomeIndex:n-1]= temp.copy()


            SS1=AddressJobs2ClustersProblem(SS1.copy())
            Sol1= genome2cluster(SS1.copy())



            #JobSize = totalMemk(Sol1)
            if (feasibleMemk(SS1)==True and isRepeated(PoP.copy(),SS1.copy()) ==False):
                #print('Cross1 len:',len(SS1))
                F=(RunningTime(SS1.copy(),Sol1.copy()))
                PoP,FiT= AddNewSol(PoP.copy(), SS1.copy(),FiT.copy(),F)  
                


            SS2=AddressJobs2ClustersProblem(SS2)
            Sol2= genome2cluster(SS2)
            #JobSize = totalMemk(Sol2)
            if (feasibleMemk(SS2.copy())==True and isRepeated(PoP.copy(),SS2.copy()) ==False):
                #print('Croos2 len:',len(SS2))
                F=(RunningTime(SS2.copy(),Sol2.copy()))
                PoP,FiT= AddNewSol(PoP.copy(), SS2.copy(),FiT.copy(),F) 
    if (len(PoP)!= len(FiT)):
        PoP,FiT= arrangeSolutions(PoP.copy())
        #print("Pop:\n", PP)
        #print("!!!Crosslen(P):",len(PoP))
        #print ("len Fit",len(FiT))
    return PoP.copy(),FiT.copy()


#==================================================================
#                 Genetic Algorithm 
#==================================================================
    
def GA_Scheduling():
    #==================================================================
    #                 Create Initial Population
    #===================================================================
    Population=[]
    MaxPopN= 1000
    Npop=0  # number of added acceptable solutions to population
    fits=[]

    Population,Fit= CreatePopulation (n)
    fits.append(Fit)
    print('initial Population',Population)
    while (Npop <population_number):
        for j in range (population_number):
            NSOL= np.zeros((2,n))
            for i in range (n):
                NSOL[0,i]=int(random.randint(0,J-1))# Random Job  number
                NSOL[1,i]=int(random.randint(0,V-1)) # Random Cluster Node number
            NSOL= AddressJobs2ClustersProblem(NSOL)   

            Sol= genome2cluster(NSOL)
            #JobSize = totalMemk(Sol)
            if (feasibleMemk(NSOL)==True and isRepeated(Population.copy(),NSOL.copy()) ==False):
                Fit= (RunningTime(NSOL,Sol))
                Population, fits= AddNewSol(Population.copy(),NSOL.copy(),fits.copy(), Fit)
                Npop+=1
    #print('initpop:',Population)
   
    #==================================================================
    #                 Genetic Algorithm 
    #===================================================================
    for iteration in range(maxIter):
        changed=False

        changed=False
        nMut=0   # number of acceptable Muted solutions 
        nCross=0 # number of acceptable Crossover solutions 
        Npop= len(Population)

        #for i in range (len (Population)):
            #print(Population[i])
        #==================================================================
        #                 Mutation
        #===================================================================
                
        #print ('Mut1:')
        #print(len(Population))
        #print(len(fits))
        Population,fits= Mutation(Population.copy(),fits.copy())
        #print ('Mut2:')
        #print(len(Population))
        #print(len(fits))
        #for i in range (len (Population)):
            #print(Population[i])
        #==================================================================
        #                Crossover
        #===================================================================
        #print ('Cros1:')
        #print(len(Population))
        #print(len(fits))
        Population,fits=Crossover (Population.copy(),fits.copy())
        #print ('Cros2:')
        #print(len(Population))
        #print(len(fits))

        #==================================================================
        #                Add Muted Solutions to Population
        #===================================================================

        ''' print ('Pop1:')
        for i in range (len (Population)):
            print(Population[i])'''
        Population, fits,Npop=SortPopulation(Population.copy(), fits.copy(), Npop-1)    
        Population,fits= arrangeSolutions(Population.copy())
        
        '''print ('Pop2:')
        for i in range (len (Population)):
            print(Population[i])'''
        print("\n***************************************************************************\n")
        print('Best Solution is of iteration of {} is:\n{} '.format(iteration,Population[0].copy() ))
        print("-----------------------------------------------------------------------------\n")
    
    return Population.copy(), fits.copy()

P, F= GA_Scheduling()


BestSolution = P[0]
ClusterName= np.unique(nodename)
print('The best solution:\n')
for i in range(n):
    j= int(BestSolution[0][i])
    k= int(BestSolution[1][i])
    print( "Genome {} is allocated to Job Number {} on Cluster Node Number {}.".format(i,j,ClusterName[k]))

print('\n and its fitness function is:\n',(F[0]))


S1=P[0]
print(feasibleMemk(S1))

print(S1)



J2C= jobs2cluster(BestSolution)
EmptyClusters=[]
for k in range(V):
    if (J2C[k]!= []):
        print('Cluster {} includes a subset of Job numbers:\n{}'.format(ClusterName[k],np.unique( J2C[k])))
    else:
        EmptyClusters.append(ClusterName[k])
print("================================================================================")
print ("Empty Clusters are:", (EmptyClusters))


G2J= Genomes2Jobs(BestSolution)
EmptyJobs=[]
for i in range(J):
    if (G2J[i]!= []):
        print('Job {} includes a subset of genomes numbers:{}'.format(i,G2J[i]))
    else:
        EmptyJobs.append(i)
print("================================================================================")
print ("Empty Jobs are:", EmptyJobs)


job0size=200+50
job0clusternodeIndex=202-201
job1size= 666
job1clusternodeIndex=203-201
job2size=0
job2clusternodeIndex=[]
job3size= 0
job3clusternodeIndex= []
job4size= 400+100
job4clusternodeIndex= 202-201

CN0JobsSize= 0
CN1JobsSize= job0size+ job4size
CN2JobsSize= job1size

FkCN0= fk(FinalOutput[0]['BestPloynomialDegree'],0,FinalOutput[0]['Coefficients'])
FkCN1= fk(FinalOutput[1]['BestPloynomialDegree'],job0size,FinalOutput[1]['Coefficients'])
+fk(FinalOutput[1]['BestPloynomialDegree'],job4size,FinalOutput[2]['Coefficients'])

FkCN2= fk(FinalOutput[2]['BestPloynomialDegree'],job1size,FinalOutput[2]['Coefficients']) 
print('FkCN0:',FkCN0)
print('FkCN1:',FkCN1)
print('FkCN2:',FkCN2)
tk0=FkCN0
tk1=FkCN1
tk2= FkCN2 + tsk[2]
print('tk0:',tk0)
print('tk1:',tk1)
print('tk2:',tk2)
print ('total tk:', max(tk0,tk1,tk2))


print(len(F))
print(len(P))
for i in range(len(P)):
    print('Jobs and for Population {} is:\t{}, {} fits={}'.format(i,P[i][0],P[i][1],F[i]))
    
print(Si)