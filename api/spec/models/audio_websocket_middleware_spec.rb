# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AudioWebSocketMiddleware do
  describe '#sanitize_output_transcription' do
    let(:middleware) { described_class.new(nil) }

    def sanitize(text)
      middleware.send(:sanitize_output_transcription, text)
    end

    it 'strips coverage map JSON echoed by the model' do
      dirty = '[COVERAGE_MAP]{"skills":[{"label":"React","state":"covered"}]}[/COVERAGE_MAP] Let me ask about that.'
      expect(sanitize(dirty)).to eq('Let me ask about that.')
    end

    it 'strips TIME CONTROL signals that leak into transcription' do
      dirty = '[TIME CONTROL:SYS-TC-7x9k] { "wrap_up": true } Okay, thank you.'
      expect(sanitize(dirty)).to eq('Okay, thank you.')
    end

    it 'strips partial JSON echoes that precede the real sentence' do
      dirty = '"} ] And finally, tell me about testing.'
      expect(sanitize(dirty)).to eq('And finally, tell me about testing.')
    end

    it 'strips pacing metadata' do
      dirty = 'pacing=behind priority_next=react What else have you built?'
      expect(sanitize(dirty)).to eq('What else have you built?')
    end

    it 'keeps clean Indonesian speech untouched' do
      clean = 'Ceritakan pengalaman Anda memimpin tim.'
      expect(sanitize(clean)).to eq(clean)
    end
  end
end