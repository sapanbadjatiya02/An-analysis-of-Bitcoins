#Installing required packages
install.packages("lubridate")
library(lubridate)

install.packages("stats4")
library(stats4)

install.packages("lmtest")
library(lmtest)

install.packages("nortest")
library(nortest)

install.packages("tseries")
library(tseries)

install.packages("forecast")
library(forecast)

install.packages("rugarch")
library(rugarch)

install.packages("ggplot2")
library(ggplot2)

install.packages("plotly")
library(plotly)

install.packages("grid")
library(grid)
##Step 1:Introduction
##Step 2:Overview
##Step 3:Data Description

##Step 4:Objective

#STEP 4.1: Objective 1: PRICE ANALYSIS

#Read data file name 'Second Dataset - Currency Data' and name the data file as CurrencyData
CurrencyData = read.csv(file.choose(), header=TRUE, sep=",", stringsAsFactors = FALSE)
View(CurrencyData)

#Changing the Date format
CurrencyData$Date= mdy(CurrencyData$Date)
str(CurrencyData)  

#a) Plot for Crytocurrency price vaiations
Ether_Plot = ggplot(CurrencyData, aes(Date)) + 
  geom_line(aes(y = CurrencyData$Ether_Price))+
  labs(x = "Date", y = "Ethereum Price $")

Bitcoin_Plot = ggplot(CurrencyData, aes(Date)) + 
  geom_line(aes(y = CurrencyData$Bitcoin_Price))+
  labs(x = "Date", y = "Bitcoin Price $")

Litecoin_Plot = ggplot(CurrencyData, aes(Date)) + 
  geom_line(aes(y = CurrencyData$Litecoin_Price))+
  labs(x = "Date", y = "Litecoin Price $")

grid.newpage()
grid.draw(rbind(ggplotGrob(Bitcoin_Plot), ggplotGrob(Ether_Plot), ggplotGrob(Litecoin_Plot), size= "last"))

#b) Plot for Percentage variation of cryptocurrencies
PercentageVariation= ggplot(CurrencyData, aes(Date)) + 
  geom_line(aes(y = CurrencyData$Ether_Change.., colour = "Ethereum")) + 
  geom_line(aes(y = CurrencyData$Bitcoin_Change.., colour = "Bitcoin"))+
  geom_line(aes(y= CurrencyData$Litecoin_Change.., color = "Litecoin"))+
  labs(x = "Date", y = "Currency Price % Change", title= "% Price Change of Bitcoin, Ethereum, Litecoin")
ggplotly(PercentageVariation)

###########################################################################
#STEP 4.2: Objective 2: ANALYZING THE CORRELATION

# Read data file name 'First Dataset - BitcoinVol' and name the data file as BitcoinVol
BitcoinVol <- read.csv(file.choose(), header=TRUE, sep=",", stringsAsFactors = FALSE)
names(BitcoinVol)

#Changing date format
BitcoinVol$Date= as.Date(as.character(BitcoinVol$Date),"%Y%m%d")
class(BitcoinVol$Date)
View(BitcoinVol)

#Finding Correlation between Market Returns and Bitcoin Returns

MarketReturn <- BitcoinVol$MarketReturn[-1116]
BitcoinReturn <- BitcoinVol$BitcoinReturn[-1116]
LinearModel1= lm(BitcoinReturn~MarketReturn, data = BitcoinVol) 
plot(BitcoinReturn~MarketReturn, data = BitcoinVol)
abline(LinearModel1)
dev.off()
summary(LinearModel1)
cor(MarketReturn, BitcoinReturn)

######################################################################

#STEP 4.3: Objective 3: NORMALITY TESTS

#To check the normality of Bitcoin Returns

#Remove NAs before conducting tests and store as new vector

#the Jarque-Bera Test
BR<- na.omit(BitcoinVol$BitcoinReturn)
jarque.bera.test(BR)

#the Lilliefors test
lillie.test(BR)

######################################################################

#STEP 4.4: Objective 4: VOLATILITY & FORECASTING 
### Define variable PriceX and create variable log price, which is the log value of PriceX
PriceX<-BitcoinVol$BitcoinPrice....
logprice<-log(PriceX)

#1: Time-series plot of log of Bitcoin Price
jpeg(filename="Case2_TimeSeriesPlotoflogofPriceX .jpeg")
plot(BitcoinVol$Date,logprice,type="l",xlab="",ylab="",
     main="Time-series plot of log of Bitcoin Price")
dev.off()
### Find the maximum
maximum<-max(logprice,na.rm=T)
maxvalue<-grepl(maximum, logprice)
findmax<-which(maxvalue)
BitcoinVol$Date[findmax]
logprice[findmax]
### Find the minimum 
minimum<-min(logprice,na.rm=T)
minvalue<-grepl(minimum, logprice)
findmin<-which(minvalue)
BitcoinVol$Date[findmin]
logprice[findmin]


#2: Time-Series Plot for the Bitcoin Returns
#Define BitcoinReturn
ReturnX<-BitcoinVol$BitcoinReturn
class(ReturnX)
jpeg(filename = "Time-series plot of Bitcoin Return.jpeg")
plot(BitcoinVol$Date,ReturnX,type = "l",xlab="",ylab = "",main="Time-series plot of Bitcoin Return")
dev.off()

#Calculate the Max point of the plot
maxRe<-max(ReturnX, na.rm = T)
maxvalueRe<-grepl(maxRe,ReturnX)
findmaxRe<-which.max(maxvalueRe)
ReturnX[findmaxRe]
BitcoinVol$Date[findmaxRe]

#Calculate the Min point of the plot
minRe<-min(ReturnX, na.rm = T)
minvalueRe<-grepl(minRe,ReturnX)
findminRe<-which(minvalueRe)
ReturnX[findminRe]
BitcoinVol$Date[findminRe]


#3: Unit Root Test
#Step 1 Dickey Fuller testing
#load in tseries package to fullfill Dickey Fuller testing
library(tseries)
adf.test(logprice,k=0)

#Step 2 Augmented Dickey Fuller testing
library(tseries)
adf.test(logprice)


#4: Estimate an ARMA(p,q) Model
#Step 3.1 Estimate an ARMA(p,q) Model
#Create a list variable to store several ARMA models
ARMA_Multiple<-list(NA)
#Create an index variable to direct the storage of ARMA models
index<-0
#Use for() function to create several ARMA models
#p:AR order; q: MA order

for(p in 0:2){
  for(q in 0:2){
    index<-index+1
    ARMA_Multiple[[index]]<-arima(ReturnX,order=c(p,0,q))
  }
}
#Generate z test of coefficients for ARMA1~ARMA9
cotest<-list(NA)
for(i in 1:9){
  cotest[[i]]<-coeftest(ARMA_Multiple[[i]])
}

#Select a model that minimizes AIC
ARMAt_AIC<-matrix(data = NA,nrow=3,ncol=3)
index<-0
for(p in 0:2){
  for(q in 0:2){
    index<-index+1
    ARMAt_AIC[p+1,q+1]<-AIC(ARMA_Multiple[[index]])
  }
}

rownames(ARMAt_AIC)<-0:2
colnames(ARMAt_AIC)<-0:2
as.table(ARMAt_AIC)
ARMA_Multiple[[which(ARMAt_AIC==min(ARMAt_AIC))]]

ARMA_Multiple[[1]]

#Select a model that minimizes BIC
ARMAt_BIC<-matrix(data = NA,nrow=3,ncol=3)

index<-0
for(p in 0:2){
  for(q in 0:2){
    index<-index+1
    ARMAt_BIC[p+1,q+1]<-BIC(ARMA_Multiple[[index]])
  }
}
rownames(ARMAt_BIC)<-0:2
colnames(ARMAt_BIC)<-0:2
as.table(ARMAt_BIC)
ARMA_Multiple[[which(ARMAt_BIC==min(ARMAt_BIC))]]

ARMA_Multiple[[1]]

#5: ARMA (0,0) Diagnosis Test 
#Choosing ARMA(0,0) model
#ARMA00, in which p=0, q=0
ARMA00<-ARMA_Multiple[[1]]

class(ARMA00)
names(ARMA00)
ARMA00$call
ARMA00$coef
ARMA00$var.coef
ARMA00$loglik
coeftest(ARMA00)
AIC(ARMA00)
BIC(ARMA00)

#Calculating residuals for ARMA00 model
ARMA_residual<-ARMA00$residuals

#Making sure the lengths of Date and residuals are equal; Removing NAs
which(is.na(ARMA_residual))
ARMA_residual[1116]
ARMA_residual<- na.omit(ARMA_residual)
DATE <- BitcoinVol$Date[-1116]
length(DATE)
length(ARMA_residual)

#ARMA(0,0) Diagnosis Test
#Disturbances error term follow a normal distribution
#Creat ARMA(0,0) Model
ARMA00<-ARMA_Multiple[[1]]

#5.1: Create box plot for ARMA(0,0) Reisduals
jpeg(filename="Case2_ARMA(0,0) Box plot for Residual.jpeg")
boxplot(ARMA_residual,xlab="",ylab="",main="ARMA(0,0) Residual")
dev.off()
median(ARMA_residual)
summary

#5.2: Create a histogram plot for ARMA(0,0) Residuals
jpeg(filename="Case2_ARMA(0,0) Histogram of the Residuals.jpeg")
hist(ARMA_residual,main="Histogram of the Residuals",xlab="Residual",prob=T,breaks=50)
dev.off()

#5.3: Create a Q-Q plot of ARMA(0,0) Residuals
jpeg(filename="Case2_ARMA(0,0) Residuals_QQ.jpeg")
qqnorm(ARMA_residual,main="Q-Q plot of Residuals")
qqline(ARMA_residual)
dev.off()

#6: Jarque-Bera Test of ARMA(0,0) Residuals
library(tseries)
jarque.bera.test(ARMA_residual)

#7: Lilliefors Test of ARMA(0,0) Residuals
library(nortest)
lillie.test(ARMA_residual)


#8: disturbances error term serially uncorrelated
#8.1: Create a Scatter plot of residual(t+1) vs residual(t)
lg<-length(ARMA_residual)
Residual1<-ARMA_residual[1:(lg-1)]
Residual2<-ARMA_residual[2:lg]
jpeg(filename="Case2_Scatter Plot of ARMA(0,0) Residuals.jpeg")
plot(Residual1,Residual2,main="Scatter Plot of Residuals",xlab="Residuals,t",
     ylab="Residuals,t+1")
dev.off()


#8.2: Ljung-Box Q-Test
htest<-Box.test(ARMA_residual,type = "Ljung",lag=5)


#9: Heteroskedasticity
#Create a time series plot for residuals
jpeg(filename="Case2_ARMA(1,1) Residuals.jpeg")
plot(DATE,ARMA_residual,type="l",main="Residuals",xlab="BitcoinVol$Date",ylab="Residuals")
dev.off()
#Find the maximum
maximum_Residual<-max(ARMA_residual,na.rm=T)
maxvalue_Residual<-grepl(maximum_Residual, ARMA00$residuals)
findmax_Residual<-which(maxvalue_Residual)
BitcoinVol$Date[findmax_Residual]
ARMA_residual[findmax_Residual]
#Find the minimum 
minimum_Residual<-min(ARMA_residual,na.rm=T)
minvalue_Residual<-grepl(minimum_Residual, ARMA00$residuals)
findmin_Residual<-which(minvalue_Residual)
BitcoinVol$Date[findmin_Residual]
ARMA_residual[findmin_Residual]


#10: ARMA(0,0) Predicted Value 
fits<-fitted(ARMA00)
### Create a time-series plot for the Bitcoin returns and fitted value
jpeg(filename="Case2_Bitocin Returns vs Fits.jpeg")
ReturnX <- ReturnX[-1116]
fits <- fits[-1116]
plot(DATE,ReturnX,type="l",xlab="Date",ylab="Returns",
     main="BitcoinReturn vs Fits")
lines(DATE,fits,col="red")
dev.off()
round(accuracy(ARMA00),6)


#Step4.7 Training and test sets 
# Case 1
#Create a time-series plot for observable 1115 days' returns and forecast future 252 days' returns
fcast<-forecast(ARMA00,h=252)
jpeg(filename="Case2_forecast case 1.jpeg")
plot(fcast)
dev.off()

# Case 2
lg<-NROW(ReturnX)
fit_no_holdout = arima(ts(ReturnX[-c((lg-252+1):lg)]), order=c(0,0,0))
fcast_no_holdout<-forecast(fit_no_holdout,h=252)
# Create a time-series plot for observable 4733 days' returns and forecast 252 days' returns
jpeg(filename="Case2_forecast case 2.jpeg")
plot(fcast_no_holdout,main="Forecasts from ARIMA(0,0,0) with non-zero mean h=252 ", col='blue')
lines(ts(ReturnX))
dev.off()
# Create a time-series plot for 252 days' actual returns and the mean of forecasting returns
jpeg(filename="Case2_forecast case 2 Forecastsh=252.jpeg")
plot(ts(ReturnX[(lg-252+1):lg]), main=" Forecasts h=252",xlab="Time",
     ylab="ts(ReturnX[(1g-252+1):lg])")
lines(1:252,fcast_no_holdout$mean,col='blue',lwd = 5)
dev.off()
round(accuracy(fcast_no_holdout,ReturnX[(lg-252+1):lg]),6)


#12: ARCH Model

#12.1: Auto-correlation plot for the squared residuals et^2
#Create variable of ARMA(0,0) residuals and variable of the square of ARMA(0,0) residuals
ARMA_residual_square<-(ARMA_residual^2)
### Construct auto-correlation plot for residuals of ARMA(0,0) model
jpeg(filename="Case2_Autocorrelation Function of Squared Residuals.jpeg")
acf(ARMA_residual_square,xlab="Lag",ylab="Sample Autocorrelation",
    main="Autocorrelation Function of Squared Residuals",lag.max=50,ylim=c(-0.2,1))
dev.off()

#12.2: Partial auto-correlation plot for the squared residuals et^2
#Construct Partial auto-correlation plot for the squared residuals of ARMA(0,0) model
jpeg(filename="Case2_Partial Autocorrelation Function of Squared Residuals.jpeg")
pacf(ARMA_residual_square,xlab="Lag",ylab="Sample Autocorrelation",
     main="Partial Autocorrelation Function of Squared Residuals",lag.max=50,ylim=c(-0.2,1))
dev.off()


#STEP 13: GARCH family
#Construct Garch(1, 1) model
garch_11<-garch(ARMA_residual, order=c(1,1))
summary(garch_11)
## Find the fitted value of Garch(1,1) model
garch_11_fitted<-garch_11$fitted.values[,1]
jpeg(filename="T-series plot of garch(1,1) implied volatility.jpeg")
plot(DATE,garch_11_fitted, type="l", main="time-series plot of GARCH(1,1) Implied Volatility",ylab="")
dev.off()

### Find the maximum
maximum_GARCH<-max(garch_11_fitted,na.rm=T)
maxvalue_GARCH<-grepl(maximum_GARCH, garch_11_fitted)
findmax_GARCH<-which(maxvalue_GARCH)
BitcoinVol$Date[findmax_GARCH]
garch_11_fitted[findmax_GARCH]
### Find the minimum 
minimum_GARCH<-min(garch_11_fitted,na.rm=T)
minvalue_GARCH<-grepl(minimum_GARCH, garch_11_fitted)
findmin_GARCH<-which(minvalue_GARCH)
BitcoinVol$Date[findmin_GARCH]
garch_11_fitted[findmin_GARCH]


#14: Time-Series plot for VIX
VIX<-BitcoinVol$Bitcoin_VIX
jpeg(filename="Case2_Time-Series Plot of VIX.jpeg")
plot(BitcoinVol$Date,VIX,type="l",main="Time-Series Plot of VIX",xlab="DATE",ylab="VIX2",col="blue")
dev.off()
### Find the maximum
maximum_VIX<-max(VIX,na.rm=T)
maxvalue_VIX<-grepl(maximum_VIX, VIX)
findmax_VIX<-which(maxvalue_VIX)
BitcoinVol$Date[findmax_VIX]
VIX[findmax_VIX]
### Find the minimum 
minimum_VIX<-min(VIX,na.rm=T)
minvalue_VIX<-grepl(minimum_VIX, VIX)
findmin_VIX<-which(minvalue_VIX)
BitcoinVol$Date[findmin_VIX]
VIX[findmin_VIX]

####################################################################################
####################################################################################


