# frozen_string_literal: true

# This class handles the logic for calculating probate fees.

class ProbateController < ApplicationController
  before_action :validate_estate_value, only: [:calculate_fee]
  def index
    @estate_value = session[:estate_value]
    @result = session[:result]&.with_indifferent_access
  end


  def calculate_fee
    estate_value = params[:estate_value].to_f
    session[:estate_value] = params[:estate_value]

    @result = calculate_probate_fee(estate_value)
    
    session[:result] = @result
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js # This will render calculate_fee.js.erb
    end
  end

  private

  def validate_estate_value
    unless params[:estate_value].present? && params[:estate_value].to_f.positive?
      render json: { error: 'Invalid estate value. Please provide a positive number.' }, status: :unprocessable_entity
    end
  end

  def calculate_probate_fee(estate_value)
    probate_fee_breakdown = []

    if estate_value <= 100_000
      probate_fee_breakdown << { range: '$0 - $100,000', percentage: '4%', amount: estate_value * 0.04 }
      total_fee = estate_value * 0.04
    elsif estate_value <= 200_000
      probate_fee_breakdown << { range: '$0 - $100,000', percentage: '4%', amount: 100_000 * 0.04 }
      probate_fee_breakdown << { range: '$100,000 - $200,000', percentage: '3%',
                                 amount: (estate_value - 100_000) * 0.03 }
      total_fee = 100_000 * 0.04 + (estate_value - 100_000) * 0.03
    elsif estate_value <= 1_000_000
      probate_fee_breakdown << { range: '$0 - $100,000', percentage: '4%', amount: 100_000 * 0.04 }
      probate_fee_breakdown << { range: '$100,000 - $200,000', percentage: '3%', amount: 100_000 * 0.03 }
      probate_fee_breakdown << { range: '$200,000 - $1,000,000', percentage: '2%',
                                 amount: (estate_value - 200_000) * 0.02 }
      total_fee = 100_000 * 0.04 + 100_000 * 0.03 + (estate_value - 200_000) * 0.02
    elsif estate_value <= 10_000_000
      probate_fee_breakdown << { range: '$0 - $100,000', percentage: '4%', amount: 100_000 * 0.04 }
      probate_fee_breakdown << { range: '$100,000 - $200,000', percentage: '3%', amount: 100_000 * 0.03 }
      probate_fee_breakdown << { range: '$200,000 - $1,000,000', percentage: '2%', amount: 800_000 * 0.02 }
      probate_fee_breakdown << { range: '$1,000,000 - $10,000,000', percentage: '1%',
                                 amount: (estate_value - 1_000_000) * 0.01 }
      total_fee = 100_000 * 0.04 + 100_000 * 0.03 + 800_000 * 0.02 + (estate_value - 1_000_000) * 0.01
    elsif estate_value <= 25_000_000
      probate_fee_breakdown << { range: '$0 - $100,000', percentage: '4%', amount: 100_000 * 0.04 }
      probate_fee_breakdown << { range: '$100,000 - $200,000', percentage: '3%', amount: 100_000 * 0.03 }
      probate_fee_breakdown << { range: '$200,000 - $1,000,000', percentage: '2%', amount: 800_000 * 0.02 }
      probate_fee_breakdown << { range: '$1,000,000 - $10,000,000', percentage: '1%', amount: 9_000_000 * 0.01 }
      probate_fee_breakdown << { range: '$10,000,000 - $25,000,000', percentage: '0.5%',
                                 amount: (estate_value - 10_000_000) * 0.005 }
      total_fee = 100_000 * 0.04 + 100_000 * 0.03 + 800_000 * 0.02 + 9_000_000 * 0.01 + (estate_value - 10_000_000) * 0.005
    else
      probate_fee_breakdown << { range: '$0 - $100,000', percentage: '4%', amount: 100_000 * 0.04 }
      probate_fee_breakdown << { range: '$100,000 - $200,000', percentage: '3%', amount: 100_000 * 0.03 }
      probate_fee_breakdown << { range: '$200,000 - $1,000,000', percentage: '2%', amount: 800_000 * 0.02 }
      probate_fee_breakdown << { range: '$1,000,000 - $10,000,000', percentage: '1%', amount: 9_000_000 * 0.01 }
      probate_fee_breakdown << { range: '$10,000,000 - $25,000,000', percentage: '0.5%', amount: 15_000_000 * 0.005 }
      probate_fee_breakdown << { range: 'Above $25,000,000', description: 'Fee to be determined by the court' }
      total_fee = 100_000 * 0.04 + 100_000 * 0.03 + 800_000 * 0.02 + 9_000_000 * 0.01 + 15_000_000 * 0.005
    end

    { total_fee:, breakdown: probate_fee_breakdown }
  end
end
