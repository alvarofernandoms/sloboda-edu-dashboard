ActiveAdmin.register Event do
  permit_params :subject, :datetime, :confirmed, :location_id,
                :user_events, :users
  before_action :set_users_before_update, only: [:update]
  after_create :set_users_after_create

  controller do
    def add_users_to_event(event_id)
      @event = Event.find(event_id)
      @event.users = []
      params[:event][:user_ids].each do |id|
        @event.users << User.find(id) unless id == ''
      end
    end

    def set_users_after_create
      add_users_to_event(id)
    end

    def set_users_before_update
      add_users_to_event(params[:id])
    end
  end

  index do
    selectable_column
    column :id
    column :subject
    column :datetime
    column :confirmed
    column :location
    column :created_at

    column :speakers do |event|
      table_for event.users.each do
        column do |user|
          link_to user.email, [:admin, user]
        end
      end
    end
    actions
  end

  show do
    attributes_table do
      row :subject
      row :location
      row :datetime
      table_for event.users.each do
        column do |user|
          link_to user.email, [:admin, user]
        end
      end
    end
  end

  form do |f|
    f.inputs 'Event' do
      f.semantic_errors(*f.object.errors.keys)
      f.input :subject
      f.input :datetime, as: :datetime_picker
      f.input :location
      f.input :confirmed

      f.input :users,
              collection: User.all.map { |user| [user.email, user.id] },
              as: :select, multiple: true
    end
    f.actions
  end

  filter :confirmed, as: :check_boxes

  scope :all, default: true
  scope :today do |events|
    events.where(datetime: DateTime.now.beginning_of_day..
                 DateTime.now.end_of_day)
  end
  scope :this_week do |events|
    events.where(datetime: DateTime.now.beginning_of_day...1.week.from_now)
  end
  scope :past do |events|
    events.where('datetime < ?', DateTime.now)
  end
end
