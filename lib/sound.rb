module Sound
    require 'fileutils'
    require 'wavefile'
    include WaveFile

    WT_FRAME_SIZE = 2048
    WT_FRAME_COUNT = 256
    WT_LENGTH = WT_FRAME_SIZE * WT_FRAME_COUNT
    WT_SAMPLE_RATE = 44100

    def write_wav(filename, data)
        Writer.new("#{filename}", Format.new(:mono, :pcm_16, WT_SAMPLE_RATE)) do |writer|
            buffer_format = Format.new(:mono, :float, WT_SAMPLE_RATE)
            buffer = Buffer.new(data, buffer_format)
            writer.write(buffer)
        end
    end
    
    def range_conversion(oldval, oldmin, oldmax, newmin, newmax)
        @newval = (((oldval - oldmin) * (newmax - newmin)) / (oldmax - oldmin)) + newmin
    end
    
    def normalize(input_data)
        # Get min/max amplitude in frame
        @output_data = input_data
        @max_amplitude = -1.01
        @min_amplitude = 1.01
        @output_data.each do |sample|
            if sample > @max_amplitude
                @max_amplitude = sample
            elsif sample < @min_amplitude
                @min_amplitude = sample
            end
        end
        # Scale down amplitude of the entire frame if necessary
        if @max_amplitude > 1.0 or @min_amplitude < -1.0
            # Scaling
            for i in 0..@output_data.length-1
                @output_data[i] = range_conversion(@output_data[i], @min_amplitude, @max_amplitude, -1.0, 1.0)
            end
        end
        return @output_data
    end
    
    def generate_sine(length, full_cycle, positive_half_cycle, amplitude)
        @pi_fragment = (Math::PI * 2) / length
        unless full_cycle
            @pi_fragment = @pi_fragment / 2
        end
        @pi_start = Math::PI - (Math::PI * 2)
        if full_cycle == false && positive_half_cycle
            @pi_start = 0.0
        end
        @wave = []
        for s in 1..length
            @sample_base = @pi_start + (@pi_fragment * s)
            # Workaround for sin returning crazy values
            if @sample_base == Math::PI
                @sample_base = 3.141
            end
            @wave.push(Math.sin(@sample_base) * amplitude)
        end
        @wave
    end

    def generate_triangle(length, full_cycle, positive_half_cycle, amplitude)
        @switch_point = length/2.0
        @wave = []
        @sample_stepping = 1.0 / (length / 4.0)
        unless full_cycle
            @switch_point = length
            @sample_stepping = @sample_stepping / 4.0
        end
        for s in 1..length
            if s > @switch_point
                @wave.push((1.0 - (@sample_stepping * (s - @switch_point))) * amplitude)
            else
                @wave.push((-1.0 + (@sample_stepping * s)) * amplitude)
            end
        end
        if full_cycle == false && positive_half_cycle
            @newwave = []
            @wave.each do |s|
                @newwave.push(s * -1)
            end
            @wave = @newwave
        end
        @wave
    end
    
    def generate_square(length, full_cycle, positive_half_cycle, amplitude)
        @switch_point = length/2.0
        @wave = []
        if full_cycle
            for s in 1..length
                if s < @switch_point
                    @wave.push(-1.0 * amplitude)
                else
                    @wave.push(1.0 * amplitude)
                end
            end
        else
            for s in 1..length
                if (positive_half_cycle)
                    @wave.push(1.0 * amplitude)
                else
                    @wave.push(-1.0 * amplitude)
                end
            end
        end
        @wave
    end
    
    def generate_sawtooth(length, full_cycle, positive_half_cycle, amplitude)
        @wave = []
        @sample_stepping = 1.0 / (length / 2)
        unless full_cycle
            @sample_stepping = @sample_stepping / 2.0
        end
        for s in 1..length
            @wave.push((-1.0 + (@sample_stepping * s)) * amplitude)
        end
        if full_cycle == false && positive_half_cycle
            @newwave = []
            @wave.each do |s|
                @newwave.push(s * -1)
            end
            @wave = @newwave.reverse
        end
        @wave
    end    
    
end