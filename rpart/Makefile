# Makefile based on
# http://www.jonzelner.net/make/latex/knitr/2015/06/19/make-watchman/

writeupdir = writeups
analysisdir = analysis


.PHONY: all knit data

all: knit

data: $(patsubst %, $(analysisdir)/%.RData, table1 table2 combinedFullFaceAndEyes table1OpenCV compareBBoxes)

# This tells us we *should* have a pdf for each Rmd.  Can't just use a wildcard
# over all pdfs in the folder, since they won't exist the first time the
# Makefile is run
knit: $(patsubst $(writeupdir)/%.Rmd, $(writeupdir)/%.pdf, $(wildcard $(writeupdir)/*.Rmd))

$(writeupdir)/%.pdf: $(writeupdir)/%.Rmd
	$(info ************  CONVERTING KNITR TO PDF  ************)
	Rscript -e "require(rmarkdown); render(input = '$<', output_format='pdf_document')"

$(writeupdir)/writeup.Rmd: data

$(analysisdir)/%.RData: $(analysisdir)/%.R
		cd $(analysisdir); Rscript $(subst .RData, .R, $(notdir $<))
