

module BioTags
    def day_index()    ;   (1..30).to_a.sample end
    def month_index()  ;   (1..12).to_a.sample end

    def age()          ;   (21..30).to_a.sample end

    def year_index()
        2013 - age
    end

    def bio_summary()
        filename = random_file_dir( BioSummaryDir )
        raise TagSolverError, "Cannot get Bio Summary from Directory : #{BioSummaryDir}" if !filename

        text = file_contents( filename )
        Spinner.new.spin( text )
    end

end
