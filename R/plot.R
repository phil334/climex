### plot.R - Functions for plotting either the 'xts' class data or the
##    fitting results
##' @title Plot multiple time series.
##' @description This function takes several \pkg{ggplot2} plots and
##'   arranges them on one page. 
##' @details Well, it is not really related to extreme value fitting
##'   and I am aware of the fact that its quite bad style to export
##'   auxiliary functions. But this one is just so handy. If the
##'   \strong{layout} is something like
##'   \code{matrix( c( 1, 2, 3, 3 ), nrow = 2, byrow = TRUE )},
##'   then plot 1 will go in the upper left, 2 will go in the upper
##'   right, and 3 will go all the way across the bottom. ggplot
##'   objects can be passed in ..., or to \strong{plotlist} (as a list
##    of \emph{ggplot} objects).
##'
##' @param plotlist Alternative way to pass \emph{ggplot} objects.
##' @param tt.title Same as \strong{main}.
##' @param main Title of the overall plot.
##' @param ... Additional arguments for ggplot.
##' @param cols Number of columns in layout. Default = 1.
##' @param layout A matrix specifying the layout. If present,
##'   \strong{cols} is ignored. 
##'
##' @family plot
##' @author Paul Teetor (original), Philpp Mueller (minor changes)
##' @examples
##' anomalies.potsdam <- anomalies( temp.potsdam )
##' multiplot( anomalies.potsdam, temp.potsdam, cols = 2, main =
##'   "Difference between the pure data of the daily maximum
##'   temperatures of the Potsdam station and their anomalies" ) 
##' @return print object.
##' @export
##' @import ggplot2
##' @import grid
multiplot <- function( plotlist = NULL, tt.title = main, main = NULL,
                      ..., cols = 1, layout = NULL ) {
  ## Make a list from the ... arguments and plotlist
  plots <- c( list( ... ), plotlist )
  numPlots = length( plots )
  ## If layout is NULL, then use 'cols' to determine layout
  if ( is.null( layout ) ) {
    ## Make the panel
    ## ncol: Number of columns of plots
    ## nrow: Number of rows needed, calculated from # of cols
    layout <- matrix( seq( 1, cols* ceiling ( numPlots/ cols ) ),
                     ncol = cols, nrow = ceiling( numPlots/ cols ) )
  }
  if ( numPlots == 1 ) {
    print( plots[[ 1 ]] )   
  } else {
    ## Set up the page
    grid.newpage()
    if ( !is.null( tt.title ) ){
      pushViewport( viewport(
          layout = grid.layout(
              nrow( layout ) + 1, ncol( layout ),
              heights = unit( rep( 1, nrow( layout ) + 1 ),
                             c( "lines", rep( "null",
                                             nrow( layout) ) ) ) ) ) )
    } else
      pushViewport( viewport(
          layout = grid.layout( nrow( layout ), ncol( layout ) ) ) )

    ## Make each plot, in the correct location
    if ( !is.null( tt.title ) ){
      grid.text( tt.title, vp = viewport(
                               layout.pos.row = 1,
                               layout.pos.col = c( 1, ncol( layout ) )
                           ) )
      for ( ii in 1 : numPlots ) {
        ## Get the i,j matrix positions of the regions that contain
        ## this subplot 
        matchidx <- as.data.frame( which( layout == ii,
                                         arr.ind = TRUE ) )
        print( plots[[ ii ]], vp = viewport(
                                 layout.pos.row = matchidx$row + 1,
                                 layout.pos.col = matchidx$col ) )
      }
    } else {
      for ( ii in 1 : numPlots ) {
        ## Get the i,j matrix positions of the regions that contain
        ## this subplot 
        matchidx <- as.data.frame( which( layout == ii,
                                         arr.ind = TRUE ) )
        print( plots[[ ii ]], vp = viewport(
                                 layout.pos.row = matchidx$row,
                                 layout.pos.col = matchidx$col ) )
      }
    }
  }
  invisible( last_plot() )
}

##' @title Plot xts class data
##' @description Plotting a \pkg{xts} time series with \pkg{ggplot2}
##'   in a convenient format. 
##'
##' @details Plots all objects of class \pkg{xts}. With the main
##'   argument a title can be provided. 
##'
##' @param data.input Class \pkg{xts} time series, which should be
##'   visualized.
##' @param main Title of the plot to generate. Default: "Time series"
##' @param ylab Label of the y-axis of the plot to generate. Default =
##'   NULL
##' @param ... Additional parameters for the multiplot function.
##'
##' @family plot
##' @export
##' @importFrom xts is.xts
##' @import ggplot2
##' @return Nothing. The multiplot function is run in the last step.
##' @author Philipp Mueller
ttplot <- function( data.input, main = "Time series", ylab = NULL ){
  if ( !is.xts( data.input ) )
    stop( "Please supply an object of class 'xts'!" )
  if ( is.null( ylab ) )
    ylab <- names( data.input )
  if ( is.null( ylab ) )
    ylab <- ""
  ## Checks if the time series has daily values or if it is blocked.
  ## In the latter case the create values can not be provided as the
  ## input of the x axis because ggplot2 does not know how to scale
  ## them. 
  x.time.unit <- index( data.input )[[ 2 ]] -
    index( data.input )[[ 1 ]]
  x.df <- data.frame( date = as.numeric( index( data.input ) ),
                     value = as.numeric( data.input ) )
  ggplot( data = x.df, aes( x = date, y = value ) ) +
    geom_point( colour = "darkorange" ) +
    geom_line( colour = "navy" ) +
    ggtitle( main ) + xlab( "Time" ) + ylab( ylab ) +
    theme_bw() +
    theme( panel.grid.major = element_line( colour = "grey75" ),
          panel.grid.minor = element_line( colour = "grey80" ) )
  return( last_plot() )
}

##' @title Plots the GEV likelihood
##' @description Generates three 2D slices of the likelihood of a
##'   provided time series. 
##'
##' @details The likelihood will be plotted around its optimal
##'   value. To determine it the time series will be fitted via
##'   \code{\link{fit.gev}}. Its also possible to provide another
##'   point the likelihood will be centered around using
##'   \strong{center}.
##'
##'   The likelihood will be calculated using the C++-based function
##'   \strong{likelihood_GEV}.
##'
##' @param time.series Data, for which the likelihood function is
##'   going to be calculated. 
##' @param location.lim Boundaries of the plotted likelihood
##'   region. Default = +/- 2.5 times the minimum value. 
##' @param scale.lim Boundaries of the plotted likelihood
##'   region. Default = +/- 2.5 times the minimum value. 
##' @param shape.lim Boundaries of the plotted likelihood
##'   region. Default = +/- 2.5 times the minimum value. 
##' @param center It set this point (3D) will be the new center of the
##'   likelihood plot. Default = NULL 
##' @param initial Initial parameters which can be provided for the
##'   fit of the time series. 
##' @param main Title for the multiplot. Default = NULL.
##' @param true.minima Provide the true minima of the neg
##'   log-likelihood function if \code{\link{fit.gev}} does not
##'   provide it in the first run. Default = NULL. 
##' 
##' @import ggplot2
##' @return returns a multiplot of planes through the negative
##'   log-likelihood of the GEV function calculated using the input
##'   time series. 
##' @author Philipp Mueller 
likelihood.plot <- function( time.series, location.lim = NULL,
                            scale.lim = NULL, shape.lim = NULL,
                            center = NULL, initial = NULL,
                            main = NULL, true.minima = NULL ){
  ## determining the center and the limits
  if ( is.null( true.minima ) ){
    time.series.mle <- fit.gev( x = time.series,
                               initial = initial,
                               silent = TRUE )$par
  } else
    time.series.mle <- true.minima
  if ( is.null( center ) )
    center <- time.series.mle
  if ( is.null( location.lim ) )
    location.lim <- c( center[ 1 ] - time.series.mle[ 1 ]* .5,
                      center[ 1 ] + time.series.mle[ 1 ]* .5 )
  if ( is.null( scale.lim ) )
    scale.lim <- c( center[ 2 ] - time.series.mle[ 2 ]* .5,
                   center[ 2 ] + time.series.mle[ 2 ]* .5 )
  if( scale.lim[ 1 ] < 0 )
    scale.lim[ 1 ] <- 0
  if ( is.null( shape.lim ) )
    shape.lim <- c( center[ 3 ] - time.series.mle[ 3 ]* .5,
                   center[ 3 ] + time.series.mle[ 3 ]* .5 )
  ## 2D likelihood
  ## some more point because its just the plane this time
  number.of.points <- 200
  ## setting the limits of the scale and shape parameter if not
  ## provided yet
  location.range <- seq( location.lim[ 1 ], location.lim[ 2 ], ,
                        number.of.points )
  scale.range <- seq( scale.lim[ 1 ], scale.lim[ 2 ], ,
                     number.of.points )
  shape.range <- seq( shape.lim[ 1 ], shape.lim[ 2 ], ,
                     number.of.points )
  loc.sc.plane <- data.frame(
      expand.grid( location.range, scale.range )[ , 1 ],
      expand.grid( location.range, scale.range )[ , 2 ],
      rep( center[ 3 ], number.of.points^ 2 ) )
  loc.sh.plane <- data.frame(
      expand.grid( location.range, shape.range )[ , 1 ],
      rep( center[ 2 ], number.of.points^ 2 ),
      expand.grid( location.range, shape.range )[ , 2 ] )
  sc.sh.plane <- data.frame(
      rep( center[ 1 ], number.of.points^ 2 ),
      expand.grid( scale.range, shape.range )[ , 1 ],
      expand.grid( scale.range, shape.range )[ , 2 ] )
  plot.plane <- function( par.plane, par.plane.names,
                         time.series = time.series ){
    names( par.plane ) <- c( "location", "scale", "shape" )
    likelihood.plane <- .Call( 'likelihood_GEV', PACKAGE = 'climex',
                              par.plane, time.series )
    ## Maybe introducing a cutoff in the likelihood values make the
    ## contour plot work again
    likelihood.plane[ likelihood.plane > 1E8 ] <- 1E8       
    min.likelihood <- min( likelihood.plane, na.rm = TRUE )
    if ( min.likelihood < 0 ){
      max.likelihood.low <- -min.likelihood* 1.5
      ## comment the next line to have a cutoff at 0 in the likelihood
      ## surface plot
      likelihood.plane <- likelihood.plane - min.likelihood + 0.01
      warning( "In some regions the likelihood is negative. An offset is used in order to still plot it in a logarithmic way" )
    } else
      max.likelihood.low <- min.likelihood* 1.5
    par.plane$likelihood <- par.plane$likelihood.low <-
      likelihood.plane
    par.plane$likelihood.low[ par.plane$likelihood.low >
                              max.likelihood.low ] <-
      max.likelihood.low
    names( par.plane ) <- c( par.plane.names, "likelihood.low",
                            "likelihood" )
    gg.plane <-
      ggplot() + geom_raster( data = par.plane,
                             aes( x = x, y = y, fill = likelihood ),
                             na.rm = TRUE ) +
      geom_contour( data = par.plane,
                   aes( x = x, y = y, z = likelihood.low ),
                   colour = grDevices::rgb( 1, .55, 0 ),
                   na.rm = TRUE ) +
      scale_fill_gradientn(
          colours = rev( RColorBrewer::brewer.pal( 7, "Blues" ) ),
          na.value = "white", trans = "log" ) +
      theme_bw()
    return( last_plot() ) 
  }
  plot.center <- data.frame( x = center[ 1 ], y = center[ 2 ],
                            z = center[ 3 ] )
  multiplot( plotlist = list(
                 plot.plane( loc.sh.plane,
                            par.plane.names = c( "x", "a", "y" ),
                            time.series ) +
                 geom_point( data = plot.center, aes( x = x, y = z ),
                            shape = 4 ) +
                 xlab( "location" ) + ylab( "shape" ),
                 plot.plane( sc.sh.plane,
                            par.plane.names = c( "a", "x", "y" ),
                            time.series ) +
                 geom_point( data = plot.center, aes( x = y, y = z ),
                            shape = 4 ) +
                 xlab( "scale" ) + ylab( "shape" ),
                 plot.plane( loc.sc.plane,
                            par.plane.names = c( "x", "y", "a" ),
                            time.series  ) +
                 geom_point( data = plot.center, aes( x = x, y = y ),
                            shape = 4 ) +
                 xlab( "location" ) + ylab( "scale" ) ),
            main = main )
}

##' @title Plots a GEV fit
##' @description Plots the GEV function fitted using
##'   \code{\link{fit.gev}} 
##'
##' @details Uses \pkg{ggplot2}.
##'
##'   Since this function is also uses in the shiny app
##'   \emph{climexUI}, the number of displayed bins has to be
##'   adjusted.
##'
##' @param x Fitted GEV object of class \emph{climex.fit.gev}.
##' @param bin.factor Multiplying the length of \strong{x} by this
##'   factor, results in the number of bins used in this plot. Default
##'   = NULL
##' @param ... Additional parameters. They won't be handled in the
##'   function. This argument is only present to ensure S3 generic
##'   consistency with respect to the \code{\link[graphics]{plot}}
##'   function.
##' 
##' @export
##' @import ggplot2
##' @return ggplot2 object.
plot.climex.fit.gev <- function( x, bin.factor = NULL, ... ){
  x.data <- x$x
  if ( is.null( bin.factor ) ){
    bin.factor <- ( ( ( length( x.data ) - 1 )*100/
                      length( x.data ) )  %/% 5 )* 0.025
  }
  bin.width <- ( ( max( x.data ) - min( x.data ) )/
                 ( bin.factor * length( x.data ) ) )* 1.1
  ## Range of the supplied data
  x.lim <- c( min( x.data, na.rm = TRUE ),
             max( x.data, na.rm = TRUE ) )
  ## The the calculated density falls below this threshold it won't
  ## get plotted anymore.
  threshold.pdf.plot <- 1E-4
  if ( x$control$extreme.type == "min" ){
    x.lim.rev <- -1 * rev( x.lim )
    ## In the beginning I used the coefficients of the GEV distribution
    ## to determine the range of evaluation of the density function. But
    ## this will fail for distributions with bigger absolute shape
    ## value. Instead I will use the range of the supplied data
    plot.gev.range <- seq( x.lim.rev[ 1 ] - x$par[ 2 ]* 10,
                          x.lim.rev[ 2 ] + x$par[ 2 ]* 10, 0.01 )
    plot.gev.data <- data.frame(
        x.plot = -1* plot.gev.range,
        y.plot = gev.density( x$par * c( -1, 1, 1 ),
                             plot.gev.range ) )
  } else if ( x$control$extreme.type == "max" ){
    ## In the beginning I used the coefficients of the GEV distribution
    ## to determine the range of evaluation of the density function. But
    ## this will fail for distributions with bigger absolute shape
    ## value. Instead I will use the range of the supplied data
    plot.gev.range <- seq( x.lim[ 1 ] - x$par[ 2 ]* 10,
                          x.lim[ 2 ] + x$par[ 2 ]* 10, 0.01 )
    plot.gev.data <- data.frame(
        x.plot = plot.gev.range,
        y.plot = gev.density( x$par, plot.gev.range ) )
  } else {
    stop( "Unexpected extreme.type in the provided fitting object" )
  }
  ## Removing all NaN to have less points and warnings
  plot.gev.data <- plot.gev.data[
      !is.nan( plot.gev.data$y.plot ), ]
  ## Cutting of the density at values below the threshold in the tails
  ## Lower tail
  plot.gev.data <- plot.gev.data[
  ( plot.gev.data$x.plot >
    plot.gev.data$x.plot[ which.max( plot.gev.data$y.plot ) ]
  ) | ( plot.gev.data$y.plot > threshold.pdf.plot ),  ]
  ## Upper tail
  plot.gev.data <- plot.gev.data[
  ( plot.gev.data$x.plot <
    plot.gev.data$x.plot[ which.max( plot.gev.data$y.plot ) ]
  ) | ( plot.gev.data$y.plot > threshold.pdf.plot ),  ]
  ## If the first and last entry is not a zero, add one!
  ## Else the density won't look like a density at all.
  if ( plot.gev.data$y.plot[ 1 ] > 0 ){
    plot.gev.data <- data.frame(
        x.plot = c( 2* plot.gev.data$x.plot[ 1 ] -
                    plot.gev.data$x.plot[ 2 ],
                   plot.gev.data$x.plot ),
        y.plot = c( 0, plot.gev.data$y.plot ) )
  }
  if ( plot.gev.data$y.plot[ nrow( plot.gev.data ) ] > 0 ){
    plot.gev.data[ nrow( plot.gev.data ) + 1, ] <-
      c( 2* plot.gev.data$x.plot[ nrow( plot.gev.data ) ] -
         plot.gev.data$x.plot[ nrow( plot.gev.data ) - 1 ],
        0 )
  }
  plot.gev.lim <- c( min( plot.gev.data$x.plot ),
                    max( plot.gev.data$x.plot ) )
  ## Determining the limits of the actual plot
  if ( plot.gev.lim[ 1 ] > x.lim[ 1 ] )
    plot.gev.lim[ 1 ] <- x.lim[ 1 ] - abs( x.lim[ 1 ] )* 0.05 
  if ( plot.gev.lim[ 2 ] < x.lim[ 2 ] )
    plot.gev.lim[ 2 ] <- x.lim[ 2 ] + abs( x.lim[ 2 ] )* 0.05
  plot.lim <- c( min( plot.gev.lim[ 1 ],
                     min( x.data ) - bin.width ),
                max( plot.gev.lim[ 2 ],
                    max( x.data) + bin.width ) )
  ## Whenever the density gets bigger than one, cut it
  if ( max( plot.gev.data$y.plot ) > 1 ){
    y.lim <- c( 0, ( max( stats::density( x.data )$y )* 1.5 ) )
  } else {
    y.lim <- NULL
  }
  ggplot() + geom_histogram(
                 data = data.frame( x = x.data ),
                 colour = grDevices::rgb( .098, .098, .44 ),
                 alpha = 1,
                 bins = bin.factor* length( x.data ),           
                 aes( x = x, y = ..density..,
                     fill = "#7171EC" ) ) +
  geom_polygon( data = plot.gev.data, alpha = 0.7,
               colour = grDevices::rgb( .098, .098, .44 ),
               aes( x = x.plot, y = y.plot,
                   fill = grDevices::rgb( 1, .55, 0 ) ) ) +            
    scale_fill_manual( values = c( "#7171EC",
                                  grDevices::rgb( 1, .55, 0 ) ),
                      labels = c( "Histogram", "Fitted GEV"  ) ) +
    theme_bw() + ylab( "Density" ) +
    coord_cartesian( xlim = plot.lim, ylim = y.lim ) +
    theme( legend.title = element_blank() )
  return( last_plot() )
}

##' @title Plot a GP fit
##' @description Plots the GP function fitted using
##'   \code{\link{fit.gpd}} 
##'
##' @details Uses \pkg{ggplot2}.
##'
##'   Since this function is also uses in the shiny app
##'   \emph{climexUI}, the number of displayed bins has to be
##'   adjusted.
##'
##' @param x Fitted GP object of class \emph{climex.fit.gpd}.
##' @param bin.factor Multiplying the length of \strong{x} by this
##'   factor, results in the number of bins used in this plot. Default
##'   = NULL
##' @param ... Additional parameters. They won't be handled in the
##'   function. This argument is only present to ensure S3 generic
##'   consistency with respect to the \code{\link[graphics]{plot}}
##'   function.
##'
##' @export
##' @import ggplot2
##' @return ggplot2 object.
plot.climex.fit.gpd <- function( x, bin.factor = NULL, ... ){
  if ( is.null( x$threshold ) ){
    stop( "Please provide a threshold argument to fit.gpd() in order to plot the result" )
  }
  x.data <- as.numeric( x$x + x$threshold )
  if ( is.null( bin.factor ) ){
    bin.factor <- ( ( ( length( x.data ) - 1 )*100/
                      length( x.data ) )  %/% 5 )* 0.025
  }
  bin.width <- ( ( max( x.data ) - min( x.data ) )/
                 ( bin.factor * length( x.data ) ) )* 1.1
  ## Range of the supplied data
  x.lim <- c( min( x.data, na.rm = TRUE ),
             max( x.data, na.rm = TRUE ) )
  ## The the calculated density falls below this threshold it won't
  ## get plotted anymore.
  threshold.pdf.plot <- 1E-4
  if ( x$control$extreme.type == "min" ){
    x.lim.rev <- -1 * rev( x.lim )
    ## In the beginning I used the coefficients of the GP distribution
    ## to determine the range of evaluation of the density function. But
    ## this will fail for distributions with bigger absolute shape
    ## value. Instead I will use the range of the supplied data
    plot.range <- seq( x.lim.rev[ 1 ] - bin.width,
                          x.lim.rev[ 2 ] + x$par[ 1 ]* 10, 0.01 )
    plot.data <- data.frame(
        x.plot = -1* plot.range,
        y.plot = gpd.density( x$par, x$threshold * -1,
                             plot.range ) )
  } else if ( x$control$extreme.type == "max" ){
    ## In the beginning I used the coefficients of the GP distribution
    ## to determine the range of evaluation of the density function. But
    ## this will fail for distributions with bigger absolute shape
    ## value. Instead I will use the range of the supplied data
    plot.range <- seq( x.lim[ 1 ] - bin.width,
                      x.lim[ 2 ] + x$par[ 1 ]* 10, 0.01 )
    plot.data <- data.frame(
        x.plot = plot.range,
        y.plot = gpd.density( x$par, x$threshold,
                             plot.range ) )
  } else {
    stop( "Unexpected extreme.type in provided object" )
  }
  ## Removing all NaN to have less points and warnings
  plot.data <- plot.data[
      !is.nan( plot.data$y.plot ), ]
  ## Cutting of the density at values below the threshold in the tails
  ## Lower tail
  plot.data <- plot.data[
  ( plot.data$x.plot >
    plot.data$x.plot[ which.max( plot.data$y.plot ) ]
  ) | ( plot.data$y.plot > threshold.pdf.plot ),  ]
  ## Upper tail
  plot.data <- plot.data[
  ( plot.data$x.plot <
    plot.data$x.plot[ which.max( plot.data$y.plot ) ]
  ) | ( plot.data$y.plot > threshold.pdf.plot ),  ]
  ## If the first and last entry is not a zero, add one!
  ## Else the density won't look like a density at all.
  if ( plot.data$y.plot[ 1 ] > 0 ){
    plot.data <- data.frame(
        x.plot = c( 2* plot.data$x.plot[ 1 ] -
                    plot.data$x.plot[ 2 ],
                   plot.data$x.plot ),
        y.plot = c( 0, plot.data$y.plot ) )
  }
  if ( plot.data$y.plot[ nrow( plot.data ) ] > 0 ){
    plot.data[ nrow( plot.data ) + 1, ] <-
      c( 2* plot.data$x.plot[ nrow( plot.data ) ] -
         plot.data$x.plot[ nrow( plot.data ) - 1 ],
        0 )
  }
  plot.lim <- c( min( plot.data$x.plot ),
                max( plot.data$x.plot ) )
  ## Using the threshold value defined above the range of
  ## the density plot will be determined
  plot.lim <- c( plot.data[[ 1 ]][
      which.min( abs( plot.data[[ 2 ]][
          1 : which.max( plot.data[[ 2 ]] ) ] -
          threshold.pdf.plot ) ) ],
      plot.data[[ 1 ]][ which.min( (
        plot.data[[ 2 ]][ which.max( plot.data[[ 2 ]] )
                         : length( plot.data[[ 2 ]] ) ] -
        threshold.pdf.plot ) ) +
        which.max( plot.data[[ 2 ]] ) - 1 ] )
  ## Determining the limits of the actual plot
  if ( plot.lim[ 1 ] > x.lim[ 1 ] )
    plot.lim[ 1 ] <- x.lim[ 1 ] - abs( x.lim[ 1 ] )* 0.05 
  if ( plot.lim[ 2 ] < x.lim[ 2 ] )
    plot.lim[ 2 ] <- x.lim[ 2 ] + abs( x.lim[ 2 ] )* 0.05
  plot.lim <- c( min( plot.lim[ 1 ],
                     min( x.data ) - bin.width ),
                max( plot.lim[ 2 ],
                    max( x.data) + bin.width ) )
  ## Whenever the density gets bigger than one, cut it
  if ( max( plot.data$y.plot ) > 1 ){
    y.lim <- c( 0, ( max( stats::density( x.data )$y )* 1.5 ) )
  } else {
    y.lim <- NULL
  }
  ggplot() + geom_histogram(
                 data = data.frame( x = x.data ),
                 colour = grDevices::rgb( .098, .098, .44 ),
                 alpha = 1,
                 bins = bin.factor* length( x.data ),
                 aes( x = x.data, y = ..density..,
                     fill = "#7171EC" ) ) +
  geom_polygon( data = plot.data, alpha = 0.7,
               colour = grDevices::rgb( .098, .098, .44 ),
               aes( x = x.plot, y = y.plot,
                   fill = grDevices::rgb( 1, .55, 0 ) ) ) +            
    scale_fill_manual( values = c( "#7171EC",
                                  grDevices::rgb( 1, .55, 0 ) ),
                      labels = c( "Histogram", "Fitted GP"  ) ) +
    theme_bw() + ylab( "Density" ) +
    coord_cartesian( xlim = plot.lim, ylim = y.lim ) +
    theme( legend.title = element_blank() )
  return( last_plot() )
}
## End of plot.R
