# Makefile based on
# http://www.jonzelner.net/make/latex/knitr/2015/06/19/make-watchman/

writeupdir = writeups
analysisdir = analysis
# For debugging
print-%: ; @echo $*=$($*)


.PHONY: all knit

all: knit

data: $(patsubst %, $(analysisdir)/%.RData, table1 table2 \
	combinedFullFaceAndEyes table1OpenCV compareBBoxes binomialregression \
	randomForests conditionalInferenceTrees \
	table1SetBB table1OpenCVBB)

# This tells us we *should* have a pdf for each Rmd.  Can't just use a wildcard
# over all pdfs in the folder, since they won't exist the first time the
# Makefile is run
knit: $(patsubst $(writeupdir)/%.Rmd, $(writeupdir)/%.pdf, $(wildcard $(writeupdir)/*.Rmd))

$(writeupdir)/%.pdf: $(writeupdir)/%.Rmd data
	$(info ************  CONVERTING KNITR TO PDF  ************)
	Rscript -e "require(rmarkdown); render(input = '$<', output_format='pdf_document')"

#$(writeupdir)/%.Rmd: data

$(analysisdir)/%.RData: $(analysisdir)/%.R
				cd $(analysisdir); Rscript $(notdir $<)
