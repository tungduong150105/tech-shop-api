module Api::V1
  class UsersController < ApplicationController
    before_action :require_admin
    before_action :set_user, only: [ :show, :update, :destroy ]

    # GET /api/v1/users
    def index
      @users = User.all
      render(json: @users.as_json(except: [ :password_digest, :created_at, :updated_at ]))
    end

    # GET /api/v1/users/customers
    def customers
      @users = User.customers
      render(json: @users.as_json(except: [ :password_digest, :created_at, :updated_at ]))
    end

    # GET /api/v1/users/admins
    def admins
      @users = User.admins
      render(json: @users.as_json(except: [ :password_digest, :created_at, :updated_at ]))
    end

    # GET /api/v1/users/:id
    def show
      render(json: @user.as_json(except: [ :password_digest, :created_at, :updated_at ]))
    end

    # PATCH /api/v1/users/:id
    def update
      if @user.update(user_params)
        render(json: @user.as_json(except: [ :password_digest, :created_at, :updated_at ]))
      else
        render(json: { errors: @user.errors.full_messages }, status: :unprocessable_entity)
      end
    end

    # DELETE /api/v1/users/:id
    def destroy
      @user.destroy
      head(:no_content)
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :phone, :address, :role)
    end
  end
end
