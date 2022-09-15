module WaveStacking
    include Sound

    def gen_table_wave_stacking(parameters, filename, rng)
        stacking_morph_chance = parameters[:morph_chance].to_f
        stacking_full_cycle_chance = parameters[:full_cycle_chance].to_f
        stacking_positive_half_cycle_chance = parameters[:positive_half_cycle_chance].to_f
        stacking_max_amplitude = parameters[:max_amplitude].to_f
        stacking_min_amplitude = parameters[:min_amplitude].to_f
        stacking_max_octave = parameters[:max_octave].to_i
        stacking_min_octave = parameters[:min_octave].to_i
        stacking_clipping = ActiveRecord::Type::Boolean.new.cast(parameters[:clipping])
        stacking_normalize_per_frame =ActiveRecord::Type::Boolean.new.cast( parameters[:normalize_per_frame])
        stacking_main_wave = parameters[:main_wave]
        stacking_subwaves = parameters[:subwaves]
        stacking_since_weight = parameters[:sine_weight].to_f
        stacking_triangle_weight = parameters[:triangle_weight].to_f
        stacking_square_weight = parameters[:square_weight].to_f
        stacking_sawtooth_weight = parameters[:sawtooth_weight].to_f

        @first_frame = []
        @next_frame = []
        @data = []
        # Generate Initial Sine Wave
        if stacking_main_wave == "sine"
            @first_frame = generate_sine(WT_FRAME_SIZE, true, true, 1.0)
        elsif stacking_main_wave == "triangle"
            @first_frame = generate_triangle(WT_FRAME_SIZE, true, true, 1.0)
        elsif stacking_main_wave == "square"
            @first_frame = generate_square(WT_FRAME_SIZE, true, true, 1.0)
        elsif stacking_main_wave == "sawtooth"
            @first_frame = generate_sawtooth(WT_FRAME_SIZE, true, true, 1.0)
        end
    
        # Push unmodified Sine
        @data += @first_frame
    
        # Generate Modified Frames
        @next_frame = @first_frame
        for f in 2..WT_FRAME_COUNT
            @sample_skip_counter = 0
            @subsine = []
            @subwave_index = 0
            for i in 0..WT_FRAME_SIZE-1
                @chance = rng.rand(0.0..1.0)
                if(@chance < stacking_morph_chance && @sample_skip_counter <= 0)
                    # Get Random Params
                    @octave = rng.rand(stacking_min_octave..stacking_max_octave)
                    @amplitude = rng.rand(stacking_min_amplitude..stacking_max_amplitude)
                    @chance = rng.rand(0.0..1.0)
                    @full_cycle = @chance < stacking_full_cycle_chance
                    @chance = rng.rand(0.0..1.0)
                    @positive_half_cycle = @chance < stacking_positive_half_cycle_chance
                    # Filter subwave candidates
                    @wavetypes = {
                        "sine" => stacking_since_weight,
                        "triangle" => stacking_triangle_weight,
                        "square" => stacking_square_weight,
                        "sawtooth" => stacking_sawtooth_weight
                    }
                    @weight_total = 0
                    @wavetypes.each do |wave, weight|
                        unless stacking_subwaves.include? wave
                            @wavetypes.delete(wave)
                        else
                            @weight_total += weight
                        end
                    end
                    @target = rng.rand(1..@weight_total)
                    @selected_wave = ""
                    @wavetypes.each do |wave, weight|
                        if @target <= weight
                            @selected_wave = wave
                            break
                        end
                        @target -= weight
                    end
                    # Generate Subwave
                    @subwave = []
                    if @selected_wave == "sine"
                        @subwave = generate_sine(WT_FRAME_SIZE / @octave, @full_cycle, @positive_half_cycle, @amplitude)
                    elsif @selected_wave == "triangle"
                        @subwave = generate_triangle(WT_FRAME_SIZE / @octave, @full_cycle, @positive_half_cycle, @amplitude)
                    elsif @selected_wave == "square"
                        @subwave = generate_square(WT_FRAME_SIZE / @octave, @full_cycle, @positive_half_cycle, @amplitude)
                    elsif @selected_wave == "sawtooth"
                        @subwave = generate_sawtooth(WT_FRAME_SIZE / @octave, @full_cycle, @positive_half_cycle, @amplitude)
                    end
                    # Set variables required for mixing in subwave
                    @sample_skip_counter = WT_FRAME_SIZE / @octave
                    @subwave_index = 0
                    # Skip subwave if it is longer than the rest of the frame
                    if @sample_skip_counter > WT_FRAME_SIZE - i
                        @sample_skip_counter = 0
                    end
                elsif @sample_skip_counter > 0
                    # Add subwave to frame
                    @next_frame[i] += @subwave[@subwave_index]
                    # Clipping
                    if stacking_clipping
                        if @next_frame[i] > 1.0
                            @next_frame[i] = 1.0
                        end
                        if @next_frame[i] < -1.0
                            @next_frame[i] = -1.0
                        end
                    end
                    # Maintain Counters
                    @subwave_index += 1
                    @sample_skip_counter -= 1
                end
            end
    
            # Normalize Frame (also done when clipping to prevent extreme DC bias)
            if stacking_normalize_per_frame
                @next_frame = normalize(@next_frame)
            end
    
            # Save finished frame
            @data += @next_frame
        end
    
        # Normalize Entire wavetable if frames weren't normalized individually
        unless stacking_normalize_per_frame
            @data = normalize(@data)
        end
    
        write_wav(filename, @data)
    end
    
end