module PseudoPwm
    include Sound

    def gen_table_pwm(parameters, filename, rng)
        pwm_max_movement = parameters[:max_movement].to_f
        pwm_osc_freq = parameters[:base_freq]
        
        @counter = 1
        @switch_point = WT_SAMPLE_RATE / pwm_osc_freq
        @direction = false
        @data = []
        for i in 1..WT_LENGTH
            if defined?(@last_sample) == nil
                # Generate Initial Sample
                @sample = rng.rand(-1.0..1.0)
            else
                # Generate High and Low Boundaries
                if @direction    
                    @low_bound = @last_sample
                    @high_bound = @last_sample + pwm_max_movement
                else
                    @low_bound = @last_sample - pwm_max_movement
                    @high_bound = @last_sample
                end
    
                # Clip Samples
                if @low_bound < -1.0
                    @low_bound = -1.0
                end
    
                if @high_bound > 1.0
                    @high_bound = 1.0
                end
    
                # Generate Next Sample
                @sample = rng.rand(@low_bound..@high_bound)
                @counter += 1
                if @counter > @switch_point
                    @counter = 0
                    @direction = !@direction
                end
            end
            @data.push(@sample)
            @last_sample = @sample
        end
        write_wav(filename, @data)
    end

end