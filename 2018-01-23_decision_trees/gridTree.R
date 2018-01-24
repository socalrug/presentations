# library(grid)
# library(tree)
# library(dplyr)

grid.leaf <- function(fill = "white",
                      yval = NULL) {
  
  grid.move.to(x=0,y=0.5)
  grid.line.to(x=0.5,y=0.5)
  grid.circle(r=unit(0.1, "cm"), gp=gpar(fill=fill))
  grid.text(yval,x=0.8, y=0.5)
}

grid.branch <- function(var = NULL,
                        high.label = NULL, 
                        low.label= NULL) {
  
  grid.move.to(x=0,y=0.5)
  grid.line.to(x=0.75,y=0.5)
  grid.move.to(x=0.75,y=1)
  grid.line.to(x=0.75,y=0)
  grid.line.to(x=1,y=0)
  grid.move.to(x=0.75,y=1)
  grid.line.to(x=1,y=1)
  
  grid.branch.annotate(var.label = var,
                       high.label = high.label, 
                       low.label = low.label)
}

grid.branch.annotate <- function(var.label,
                                 high.label,
                                 low.label) {
  
  # Perform arg check
  if (missing(var.label))
    stop("Variable label missing")
  if (!is.character(var.label))
    stop("Variable label must be a character")
  if (!is.character(high.label))
    stop(paste0("High label for", var.label,
                "must be a character"))
  if(!is.character(low.label))
    stop(paste0("Low label for", var.label,
                "must be character"))
  
  # Determine longest input string
  max.string <- longest.string(var.label, high.label, low.label)
  
  # Layout to vertically align text
  vplay <- grid.layout(1, 3,
                       widths=unit(c(1, 1, 0.25),
                                   c("null", "strwidth", "npc"),
                                   list(NULL, max.string, NULL)))
  
  pushViewport(viewport(layout=vplay, name = "top"))
  pushViewport(viewport(layout.pos.col=2))
  
  # Divide text column in half
  vplay2 <- grid.layout(2, 1)
  
  pushViewport(viewport(layout=vplay2))
  pushViewport(viewport(layout.pos.row=1))
  
  # Layout high bound and variable name in top half
  vplay3 <- grid.layout(3, 1,
                        heights=unit(c(1, 1, 1),
                                     c("line", "null", "line")))
  
  pushViewport(viewport(layout=vplay3))
  pushViewport(viewport(layout.pos.row=1))
  
  grid.text(high.label, just="left")
  
  popViewport()
  pushViewport(viewport(layout.pos.row=3))
  
  grid.text(var.label)
  
  popViewport(3)
  
  pushViewport(viewport(layout.pos.row=2))
  
  # Layout low bound in bottom half
  vplay4 <- grid.layout(2, 1,
                        heights=unit(c(1,1),
                                     c("null", "line")))
  
  pushViewport(viewport(layout=vplay4))
  
  pushViewport(viewport(layout.pos.row=2))
  
  grid.text(low.label, just="left")
  
  popViewport(6)
}

get.node.details <- function(df, node=1) {
  
  list(var = as.character(df[as.character(node), ]$var),
       high.label = as.character(df[as.character(node), ]$cutright),
       low.label = as.character(df[as.character(node), ]$cutleft),
       yval = as.character(df[as.character(node), ]$yval))
}

# Determine longest input string
longest.string.length <- function(x, y, z) {
  
  string.list <- c(x, y, z)
  max.string <- string.list[nchar(string.list)==max(nchar(string.list))]
  if (length(max.string) > 1) {
    max.string = max.string[[1]]
  }
  max.string <- paste0(max.string, " ") # add margin
  stringWidth(max.string)
}

longest.string <- function(x, y, z) {
  string.list <- c(x, y, z)
  max.string <- string.list[nchar(string.list)==max(nchar(string.list))]
  paste0(max.string, " ") # add margin
}

grid.grow <- function(df, node=1,
                      vp) {
  
  if (missing(vp)) {
    vp <- viewport(x=unit(0.1, "npc"),
                   y=unit(0.5, "npc"),
                   width=unit(0.1, "npc"),
                   height=unit(0.5,"npc"))
  }
  
  node.details <- get.node.details(df=df, node=node)
  
  string.length <- longest.string.length(node.details$var,
                                         node.details$high.label,
                                         node.details$low.label)
  string.height <- stringHeight(node.details$var)
  
  vp$width <- unit.pmax(vp$width, string.length*1.4) # empirically determined multiplier
  vp$height <- unit.pmax(vp$height, string.height*6)
    
  pushViewport(vp)
  
  if (is.na(node.details$var)) {
    invisible()
  }
  else if (node.details$var == "<leaf>") {
    grid.leaf(yval=node.details$yval)
  }
  else {
    grid.branch(var = node.details$var,
                high.label = node.details$high.label,
                low.label = node.details$low.label)
    
    currentvp <- current.viewport()
    
    vp.down <- viewport(x = unit(1, "npc") + 0.5*currentvp$width,
                        y = unit(0, "npc"),
                        width = currentvp$width,
                        height = currentvp$height,
                        gp=gpar(),
                        name = "downChild")
    grid.grow(df, node*2, vp=vp.down)
    popViewport()
    
    vp.up <- viewport(x = unit(1, "npc") + 0.5*currentvp$width,
                      y = unit(1, "npc"),
                      width = currentvp$width,
                      height = currentvp$height,
                      gp=gpar(),
                      name = "upChild")
    grid.grow(df, node*2+1, vp=vp.up)
    popViewport()
  }
}

grid.tree <- function(tree.in,
                      vp = viewport(name = "treeCanvas",
                                    gp=gpar(fontsize=10)),
                      color.by = NULL,
                      new.page = TRUE) {
  
  if(inherits(tree.in, "singlenode"))
    stop("Cannot plot a single node tree")
  if(!inherits(tree.in, "tree"))
    stop("First argument must be of class tree")
  if(is.null(tree.in$frame))
    stop("Tree data frame is null")
  if(nrow(tree.in$frame) < 1)
    stop("Tree data frame is empty")
  
  tree.df <- tree.in$frame
  tree.splits <- unlist(tree.df$splits)
  tree.df <- cbind(tree.df, tree.splits)

  if (is.numeric(tree.df$yval)) {
    tree.df$yval <- round(tree.df$yval, digits=2)
  }
  
  if (new.page) {
    grid.newpage()
  }
  
  pushViewport(vp)
  grid.grow(tree.df)
  popViewport()
}