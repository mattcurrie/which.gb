SRCDIR   = src
OBJDIR   = build

SOURCES  := $(wildcard $(SRCDIR)/*.asm)
OBJECTS  := $(SOURCES:$(SRCDIR)/%.asm=$(OBJDIR)/%.o)
ROMS  := $(SOURCES:$(SRCDIR)/%.asm=$(OBJDIR)/%.gb)

all: $(OBJDIR) $(ROMS)

$(OBJDIR):
	@echo "Creating $(directory)..."
	mkdir -p $@

$(ROMS): $(OBJDIR)/%.gb : $(OBJDIR)/%.o
	rgblink -n $(basename $@).sym -m $(basename $@).map -o $@ $<
	rgbfix -t "WHICH.GB" -v -p 255 $@

-include $(OBJECTS:.o=.d)

$(OBJECTS): $(OBJDIR)/%.o : $(SRCDIR)/%.asm
	rgbasm -i mgblib/ -M $(OBJDIR)/$*.d -o $@ $<

.PHONY: clean
clean:
	rm -rf $(OBJDIR)