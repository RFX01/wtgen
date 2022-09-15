// these get updated on change
var base_waveform = "sine";
var min_oct = 3;
var max_oct = 9;
var min_amp = 0.1;
var max_amp = 0.4;

var base_freq = 63;

function set_wave(wave)
{
    base_waveform = wave;
    $('#basewave-button').text(base_waveform.charAt(0).toUpperCase() + base_waveform.slice(1) + " ");
}

function set_hz(freq)
{
    base_freq = freq;
    $('#basefreq-button').text(freq + " Hz ");
}


function get_wt_wave_stacking()
{
    // Gather parameters
    var morph_prob = $('#morph-probability')[0].innerHTML;
    var full_cycle_prob = $('#full-cycle-probability')[0].innerHTML;
    var positive_half_cycle_prob = $('#positive-half-cycle-probability')[0].innerHTML;
    var clipping = $('#clipping')[0].checked;
    var normalize_frames = $('#normalize-frames')[0].checked;
    
    var subwaves = [];

    if ($('#enable-sine')[0].checked)
    {
        subwaves.push("sine");
    }

    if ($('#enable-triangle')[0].checked)
    {
        subwaves.push("triangle");
    }

    if ($('#enable-square')[0].checked)
    {
        subwaves.push("square");
    }

    if ($('#enable-sawtooth')[0].checked)
    {
        subwaves.push("sawtooth");
    }

    var sine_weight = $('#weight-sine')[0].innerHTML;
    var triangle_weight = $('#weight-triangle')[0].innerHTML;
    var square_weight = $('#weight-square')[0].innerHTML;
    var sawtooth_weight = $('#weight-sawtooth')[0].innerHTML;

    var wt_data = JSON.stringify( { 
        "gen_type": "wave_stacking",
        "morph_chance": morph_prob,
        "full_cycle_chance": full_cycle_prob,
        "positive_half_cycle_chance": positive_half_cycle_prob,
        "max_amplitude": max_amp,
        "min_amplitude": min_amp,
        "max_octave": max_oct,
        "min_octave": min_oct,
        "clipping": clipping,
        "normalize_per_frame": normalize_frames,
        "main_wave": base_waveform,
        "subwaves": subwaves,
        "sine_weight": sine_weight,
        "triangle_weight": triangle_weight,
        "square_weight": square_weight,
        "sawtooth_weight": sawtooth_weight
    } )

    // Request Wave
    request_wave(wt_data);
}

function get_wt_pseudo_pwm()
{
    var max_movement = $('#max-movement')[0].innerHTML;

    var wt_data = JSON.stringify( { 
        "gen_type": "pseudo_pwm",
        "base_freq": base_freq,
        "max_movement": max_movement
    } )

    request_wave(wt_data);
}

function request_wave(data_string)
{
    $.ajax({
        url: '/generate/wavetable',
        type: 'post',
        contentType: 'application/json',
        xhrFields: {
            responseType: 'blob'
        },
        data: data_string,
        processData: false,
        success: function(blob, status, xhr) {
            // check for a filename
            var filename = "";
            var disposition = xhr.getResponseHeader('Content-Disposition');
            if (disposition && disposition.indexOf('attachment') !== -1) {
                var filenameRegex = /filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/;
                var matches = filenameRegex.exec(disposition);
                if (matches != null && matches[1]) filename = matches[1].replace(/['"]/g, '');
            }
    
            if (typeof window.navigator.msSaveBlob !== 'undefined') {
                // IE workaround for "HTML7007: One or more blob URLs were revoked by closing the blob for which they were created. These URLs will no longer resolve as the data backing the URL has been freed."
                window.navigator.msSaveBlob(blob, filename);
            } else {
                var URL = window.URL || window.webkitURL;
                var downloadUrl = URL.createObjectURL(blob);
    
                if (filename) {
                    // use HTML5 a[download] attribute to specify filename
                    var a = document.createElement("a");
                    // safari doesn't support this yet
                    if (typeof a.download === 'undefined') {
                        window.location.href = downloadUrl;
                    } else {
                        a.href = downloadUrl;
                        a.download = filename;
                        document.body.appendChild(a);
                        a.click();
                    }
                } else {
                    window.location.href = downloadUrl;
                }
    
                setTimeout(function () { URL.revokeObjectURL(downloadUrl); }, 100); // cleanup
            }
        },
        error: function( jqXhr, textStatus, errorThrown ){
            console.log( errorThrown );
        }
    });
}