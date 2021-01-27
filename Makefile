run:
	@bash -c './covid-check.sh'
debug:
	@bash -c 'DEBUG=1 ./covid-check.sh'
clean:
	@bash -c "rm data/{earliest,slots.json}"
