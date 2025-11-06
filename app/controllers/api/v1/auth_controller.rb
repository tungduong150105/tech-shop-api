module Api::V1
  class AuthController < ApplicationController
    skip_before_action :authenticate_user, only: [ :register, :login ]

    # POS /api/v1/auth/register
    def register
      user = User.new(user_params)

      if user.save
        token = user.generate_token
        render(
          json: {
            success: true,
            message: "User registered successfully",
            user: user.as_json(expect: [ :password_digest, :created_at, :updated_at ]),
            token: token
          }
        )
      else
        render(
          json: {
            success: false,
            errors: user.errors.full_messages
          },
          status: :unprocessable_entity
        )
      end
    end

    # POST /api/v1/auth/login
    def login
      user = User.find_by(email: params[:email])

      if user&.authenticate(params[:password])
        token = user.generate_auth_token
        render(
          json: {
            success: true,
            message: "Login successful",
            user: user.as_json(except: [ :password_digest, :created_at, :updated_at ]),
            token: token
          }
        )
      else
        render(
          json: {
            success: false,
            errors: "Invalid email or password"
          },
          status: :unauthorized
        )
      end
    end

    # GET /api/v1/auth/me
    def me
      render(
        json: {
          success: true,
          user: @current_user.as_json(except: [ :password_digest, :created_at, :updated_at ])
        }
      )
    end

    # PATCH /api/v1/auth/update_profile
    def update_profile
      if current_user.update(profile_params)
        render(
          json: {
            success: true,
            message: "Profile updated successfully",
            user: current_user.as_json(except: [ :password_digest, :created_at, :updated_at ])
          }
        )
      else
        render(
          json: {
            success: false,
            errors: current_user.errors.full_messages
          },
          status: :unprocessable_entity
        )
      end
    end

    # POST /api/v1/auth/change_password
    def change_password
      if current_user.authenticate(params[:current_password])
        if current_user.update(password: params[:new_password])
          render(
            json: {
              success: true,
              message: "Password changed successfully"
            }
          )
        else
          render(
            json: {
              success: false,
              errors: current_user.errors.full_messages
            },
            status: :unprocessable_entity
          )
        end
      else
        render(
          json: {
            success: false,
            error: "Current password is incorrect"
          },
          status: :unauthorized
        )
      end
    end

    private

    def user_params
      params.require(:user).permit(:name, :email, :password, :phone, :address, :role)
    end

    def profile_params
      params.require(:user).permit(:name, :phone, :address)
    end
  end
end
