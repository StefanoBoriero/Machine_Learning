library(e1071)
library(TunePareto) # for generateCVRuns()
hitter <- read.csv("/Users/riccardosimionato/Music/iTunes/iTunes Media/Podcasts/hitter_refactored.CSV", header=TRUE, sep =",")
library(kernlab)


#CV part
k <- 10
target <- hitter[,22]
#target <- hitter$Annual_salary


#train on TR data
for (cost in 10^seq(-2,3))
{
  for (g in 2^seq(-2,3))
    
  {
    
    CV.folds <- generateCVRuns(target, ntimes=1, nfold=k, stratified=TRUE)
    
    cv.results <- matrix (rep(0,4*k),nrow=k)
    colnames (cv.results) <- c("k","fold","TR error","VA error")
    
    cv.results[,"TR error"] <- 0
    cv.results[,"VA error"] <- 0
    cv.results[,"k"] <- k
    
    
  
        for (j in 1:k)
          
        {
          
          
          
          # get VA data
          va <- unlist(CV.folds[[1]][[j]])
          #va <- unlist(inTraining[j])
          trainset <- hitter[-va,]
          valset <- hitter[va,]
          #valset2 <- valset[,1:2]
          target <- trainset[,22]
          #target <- trainset$Annual_salary
          targetval <- valset$Annual_salary
          
          #model.rad <- svm(target~trainset[,7]+ trainset[, 9] + trainset[,10] + trainset[,19],C=cost, gamma=g, kernel = "radial", data = hitter)
          
          model.rad  <- svm(target~ trainset$Number.of.times.at.bat.in.1986 + trainset$Hits_percentage_carrer + trainset$number.of.years.in.the.major.leagues  + trainset$number.of.put.outs.in.1986 + trainset$Run_percentage_in_1986 , C=cost, gamma=g, kernel = "linear", data = hitter)
          
          
          # predict TR data
          pred.va <- predict (model.rad, trainset)
          
          
          N <- dim(trainset)[1]
         
          e <- 0
          temp <- 0
          norm.root.mse.tes = NULL
          for(i in 1:N){
            e = (trainset[i,22] - pred.va[i])^2
            temp = e + temp
          }
          norm.root.mse.test <- sqrt((temp)/((N-1)*var(trainset[,22])))
          
          cv.results[j,"TR error"] <- norm.root.mse.test
          summary(model.rad)
          
          
          # predict VA data
          pred.va <- predict (model.rad, newdata=valset)
          
          N <- dim(valset)[1]
          e = NULL
          temp <- 0

          norm.root.mse.test = 0
          for(i in 1:N){
            e = (valset[i,22] - pred.va[i])^2
            temp = e + temp
          }
          
          norm.root.mse.test <- sqrt((temp)/((N-1)*var(valset[,22])))
          

          cv.results[j,"VA error"] <- norm.root.mse.test
          cv.results[j,"fold"] <- j
          
        }
        ## have a look at the results ...
        cv.results
        
        
        
        ## What one really uses is the average of the last column
        (VA.error <- mean(cv.results[,"VA error"]))
        
        nome <- paste('RAD_cv_c=',cost,'g=',g,'.txt')
        nome2 <- paste('RAD_VA_error_c=',cost,'g=',g,'.txt')
        write.table(cv.results, file=nome, row.names=F)
        write.table(VA.error, file=nome2, row.names=F)
        
      }
    
  
}


