\name{OmexDia}
\alias{OmexDia}

\title{Carbon, Nitrogen and Oxygen Diagenesis in Marine Sediments}

\description{
  Model describing the dynamics of carbon, nitrogen and
  oxygen in a marine sediment. (Soetaert et al., 1996 a,b).

  The model describes six state variables, in several hundreds of layers:
  \itemize{
    \item 2 fractions of organic carbon (FDET,SDET): fast and slow
      decaying, solid substance.

    \item oxygen (O2), dissolved substance.

    \item nitrate (NO3), dissolved substance,

    \item ammonium (NH3), dissolved substance,

    \item oxygen demand unit (ODU), dissolved substance, as lump sum of
     all reduced substances other than ammonium.
  }

  See Soetaert et al., 1996 for further details of the model.

  For the numerical approximation of these partial differential
  equations in \R, see Soetaert and Herman, 2008.

}
\usage{OmexDia()}

\format{An S4 object according to the \code{\link[simecol]{odeModel}}
  specification.

  The object contains the following slots:

  \itemize{
    \item \code{main}   Model specifications.

    \item \code{parms} Vector with the named parameters of the model - see
      code.

    \item \code{times} Simulation time and integration interval (if
      dynamic simulation); not used if the steady-state is estimated.

    \item \code{solver} User supplied solver function that calls
      \code{steady.1D} with appropriate simulation control parameters and
      re-arranges output data.

    \item \code{initfunc} Function that initialises the state variables
      and calculates the sediment grid, porosity and bioturbation
      profiles.
  }

  The model is solved to steady-state using steady-state solver.
  \code{\link[rootSolve]{steady.1D}} from package
  \code{\link[rootSolve]{rootSolve}}.

  The output consists of a list with the following elements:

  \itemize{
    \item \code{y} a data.frame with the profiles of FDET, SDET,
    O2, NO3, NH3 and ODU, units of micromol/l (solid or liquid).

    \item \code{Cflux}, \code{O2flux}, \code{NH3flux}, \code{NO3flux},
      and \code{ODUflux}, the fluxes of carbon, oxygen, ammonium,
      nitrate and ODU across the sediment-water interface , units of
      nmol/cm2/day.
  }
}

\author{Karline Soetaert}

\examples{

# create an instance of the model
myOmexDia <- OmexDia()

# show model code
print(main(myOmexDia))

# show the parameters
parms(myOmexDia)    # or myOmexDia@parms

# Note that the model has a specialized solver function built in:
solver(myOmexDia)


#====================#
# 3 Model runs       #
#====================#

# three runs with different deposition rates
parms(myOmexDia)["MeanFlux"] <- 15000/12*100/365  # nmol/cm2/day  - Carbon deposition: 15gC/m2/yr
sol  <- out(sim(myOmexDia))$y
FDET <- sol$FDET
SDET <- sol$SDET
O2   <- sol$O2
NO3  <- sol$NO3
NH3  <- sol$NH3
ODU  <- sol$ODU


parms(myOmexDia)["MeanFlux"]   <- 50000/12*100/365  # nmol/cm2/day  - Carbon deposition: 50gC/m2/yr
sol  <- out(sim(myOmexDia))$y
FDET <- cbind(FDET,sol$FDET)
SDET <- cbind(SDET,sol$SDET)
O2   <- cbind(O2 ,sol$O2 )
NO3  <- cbind(NO3,sol$NO3)
NH3  <- cbind(NH3,sol$NH3)
ODU  <- cbind(ODU,sol$ODU)

parms(myOmexDia)["MeanFlux"]   <- 2000/12*100/365  # nmol/cm2/day  - Carbon deposition: 2gC/m2/yr
sol  <- out(sim(myOmexDia))$y
FDET <- cbind(FDET,sol$FDET)
SDET <- cbind(SDET,sol$SDET)
O2   <- cbind(O2 ,sol$O2 )
NO3  <- cbind(NO3,sol$NO3)
NH3  <- cbind(NH3,sol$NH3)
ODU  <- cbind(ODU,sol$ODU)

#====================#
# plotting           #
#====================#
par(mfrow=c(2,2))
TOC  <- (FDET+SDET)*1200/10^9/2.5     # % organic carbon (excess)

Depth    <- inputs(myOmexDia)$boxes$Depth
matplot(TOC,Depth,ylim=c(15,0),xlab="procent" ,main="TOC",
        type="l",lwd=2)
matplot(O2,Depth,ylim=c(15,0),xlab="mmol/m3" ,main="O2",
        type="l",lwd=2)
matplot(NO3,Depth,ylim=c(15,0),xlab="mmol/m3" ,main="NO3",
        type="l",lwd=2)
matplot(NH3,Depth,ylim=c(15,0),xlab="mmol/m3" ,main="NH3",
        type="l",lwd=2)

legend ("bottom",col=1:3,lty=1:3,lwd=2,
legend=c("15gC/m2/yr","50gC/m2/yr","2gC/m2/yr"),title="flux")

mtext(outer=TRUE,side=3,line=-2,cex=1.5,"OMEXDIAmodel")

# The following example takes a while, so we skip it during package
# check. However, it can be simulated without problems by the user.
\dontrun{
# 2. DYNAMIC RUN
#--------------------------------
# new instance of the model
dynOmexDia <- OmexDia()
parms(dynOmexDia)["MeanFlux"] <- 15000/12*100/365  # 15gC/m2/yr

# steady-state solution used to initialise dynamic run
sol  <- out(sim(dynOmexDia))$y

init(dynOmexDia) <- unlist(sol)

N    <- parms(dynOmexDia)["N"]

# run for one year
Times <- 0:365
times(dynOmexDia) <- Times

# different solver: dynamic simulation
solver(dynOmexDia) <- function(y, times, func, parms, ...)
    ode.1D(y, times=times, func, parms, nspec=6, ...)

# this takes a while...
dyna  <- out(sim(dynOmexDia))
CONC  <- dyna [,-1] # remove time column

#====================#
# Plotting output    #
#====================#
par(mfrow=c(2,2))
O2    <- as.matrix(CONC[,(2*N+1):(3*N)])
femmecol<- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan",
                 "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))

image(x=Times,y=Depth,z=O2,col= femmecol(100),xlab="time, days",
        ylim=c(5,0),ylab= "Depth, cm",main="Oxygen, mmol/m3")
contour(x=Times,y=Depth,z=O2, add = TRUE)

NO3    <- as.matrix(CONC[,1+(3*N+1):(4*N)])
image(x=Times,y=Depth,z=NO3,col= femmecol(100),xlab="time, days",
        ylim=c(15,0),ylab= "Depth, cm",main="Nitrate, mmol/m3")
contour(x=Times,y=Depth,z=NO3, add = TRUE)

NH3    <- as.matrix(CONC[,(4*N+1):(5*N)])
image(x=Times,y=Depth,z=NH3,col= femmecol(100),xlab="time, days",
        ylim=c(15,0),ylab= "Depth, cm",main="Ammonium, mmol/m3")
contour(x=Times,y=Depth,z=NH3, add = TRUE)

mtext(outer=TRUE,side=3,line=-2,cex=1.5,"OMEXDIAmodel")

Cflux  <- CONC[,6*N+1]
O2flux <- CONC[,6*N+2]
matplot(Times,cbind(Cflux,O2flux),type="l",ylab="nmol/cm2/d",lwd=2,
        main="Fluxes")
legend("topright",c("Carbon","Oxygen"),col=c(1,2),lwd=2)
}
}
\references{
  
  Soetaert K, PMJ Herman and JJ Middelburg, 1996. A model of early
  diagenetic processes from the shelf to abyssal
  depths. Geochim. Cosmochim. Acta, 60(6):1019-1040.

  Soetaert K, PMJ Herman and JJ Middelburg, 1996b.  Dynamic response of
  deep-sea sediments to seasonal variation: a model.
  Limnol. Oceanogr. 41(8): 1651-1668.

  Soetaert K and PMJ Herman, 2008. A practical guide to ecological
  Modelling - using R as a simulation platform. Springer.

}

\seealso{
  R-package \code{\link[simecol]{simecol-package}} for a description of the
  \code{\link[simecol:simecol-package]{simObj}} class

  \code{\link{OmexDiaDLL}}, the FORTRAN-version of the omexdia model

}

\keyword{ misc }
