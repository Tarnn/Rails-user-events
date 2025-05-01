# app/services/user_event_creator.rb
class UserEventCreator
  Result = Struct.new(:success?, :user_event, :errors, keyword_init: true)

  def initialize(user_id)
    @user_id = user_id
  end

  def call
    user = find_user
    return failure_result(["User with ID #{@user_id} not found"]) unless user

    user_event = build_user_event(user)
    if user_event.save
      success_result(user_event)
    else
      failure_result(user_event.errors.full_messages)
    end
  end

  private

  def find_user
    User.find_by(id: @user_id)
  end

  def build_user_event(user)
    UserEvent.new(
      user_id: @user_id,
      event_name: fetch_event_name(user),
      entity_id: fetch_entity_id(user),
      entity_product: fetch_entity_product(user),
      properties: build_properties(user)
    )
  end

  def fetch_event_name(user)
    # Example: Derive from a related table or context
    # Replace with your logic (e.g., query a UserAction or Product table)
    action = UserAction.find_by(user_id: user.id) if defined?(UserAction)
    action&.action_type || default_event_name
  end

  def fetch_entity_id(user)
    # Example: Fetch from a related table (e.g., Product or Entity)
    # Replace with your logic
    product = Product.find_by(user_id: user.id) if defined?(Product)
    product&.id || default_entity_id
  end

  def fetch_entity_product(user)
    # Example: Fetch from a related table
    # Replace with your logic
    product = Product.find_by(user_id: user.id) if defined?(Product)
    product&.product_type || default_entity_product
  end

  def build_properties(user)
    # Fetch properties like product_id, last_product_id
    # Replace with your logic
    product = Product.find_by(user_id: user.id) if defined?(Product)
    if product
      {
        product_id: product.id,
        last_product_id: product.last_product_id || nil
      }.compact
    else
      {}
    end
  end

  def default_event_name
    # Fallback; replace with your default
    "user_action"
  end

  def default_entity_id
    # Fallback; replace with your default or raise an error
    1
  end

  def default_entity_product
    # Fallback; replace with your default
    "default_product"
  end

  def success_result(user_event)
    Result.new(success?: true, user_event: user_event, errors: [])
  end

  def failure_result(errors)
    Result.new(success?: false, user_event: nil, errors: Array(errors))
  end
end
