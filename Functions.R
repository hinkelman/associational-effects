
selectivity <- function(gud1, ipd1, gud2, ipd2){
  log(gud1/ipd1)/(log(gud1/ipd1) + log(gud2/ipd2))
}