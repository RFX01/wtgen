class GeneratorController < ApplicationController
    include WaveStacking
    include PseudoPwm
    require 'fileutils'
    skip_before_action :verify_authenticity_token

    def wavetable
        @gen_type = params[:gen_type]
        @seed = Random.new_seed
        @rng = Random.new(@seed)
        @filename = "/tmp/#{@gen_type}_#{@seed.to_s(36)}.wav"

        if @gen_type == "wave_stacking"
            gen_table_wave_stacking(params, @filename, @rng)
        elsif @gen_type == "pseudo_pwm"
            gen_table_pwm(params, @filename, @rng)
        end

        send_file(
            @filename,
            filename: @filename.split('/')[2],  # get filename only but kinda dirty
            type: "audio/x-wav"
        )

    end

end