# program name
APP = writer

# Compiler
CXX = $(CROSS_COMPILE)gcc

ifeq ($(CROSS_COMPILE), )
	CXXFLAGS = -Wall -Wextra 
else
	CXXFLAGS = aarch64-none-linux-gnu- -Wall -Wextra -pedantic
endif



# Directories
SRCDIR = ./
BINDIR = ./



# Source files
SOURCES = $(wildcard $(SRCDIR)/*.c)

# Object files
OBJECTS = $(SOURCES:$(SRCDIR)/%.cpp=$(BINDIR)/%.o)

# Executable
EXECUTABLE = $(BINDIR)/$(APP)

# Rule to compile source files
$(BINDIR)/%.o: $(SRCDIR)/%.c
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Rule to link object files
$(EXECUTABLE): $(OBJECTS)
	$(CXX) $(CXXFLAGS) $^ -o $@

# Clean rule
clean:
	rm -f $(APP) *.o
