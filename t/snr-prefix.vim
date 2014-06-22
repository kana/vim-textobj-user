call vspec#hint({'sid': 'textobj#user#_sid()'})

let g:__FILE__ = expand('<sfile>')

describe 's:snr_prefix'
  context 'in a ordinary situation (verbose=0)'
    it 'works'
      0 verbose Expect Call('s:snr_prefix', g:__FILE__) =~# "^\<SNR>\\d\\+_$"
    end
  end

  context 'in a weird situation (verbose=14)'
    it 'works'
      14 verbose Expect Call('s:snr_prefix', g:__FILE__) =~# "^\<SNR>\\d\\+_$"
    end
  end

  context 'in a weird situation (verbose=15)'
    it 'works'
      15 verbose Expect Call('s:snr_prefix', g:__FILE__) =~# "^\<SNR>\\d\\+_$"
    end
  end
end
