require 'fake_sqs/queues'

describe FakeSQS::Queues do

  let(:queue_factory) { double :queue_factory, :new => double }
  subject(:queues) { FakeSQS::Queues.new(queue_factory: queue_factory) }

  describe "#create" do

    it "creates new queues" do
      queues.should have(0).queues
      create_queue("test")
      queues.should have(1).queues
    end

    it "uses the queue factory" do
      params = double :params
      queue_factory.should_receive(:new).with(params)
      create_queue("test", params)
    end

    it "returns the queue" do
      queue = double
      queue_factory.stub(:new).and_return(queue)
      create_queue("test").should eq queue
    end

    it "cannot create a queue with the same name" do
      create_queue("test")
      expect {
        create_queue("test")
      }.to raise_error(FakeSQS::QueueNameExists, "test")
    end

  end

  describe "#delete" do

    it "deletes an existing queue" do
      create_queue("test")
      queues.should have(1).queues
      queues.delete("test")
      queues.should have(0).queues
    end

    it "cannot delete an non-existing queue" do
      expect {
        queues.delete("test")
      }.to raise_error(FakeSQS::NonExistentQueue, "test")
    end

  end

  describe "#list" do

    it "returns all the queues" do
      queue1 = create_queue("test-1")
      queue2 = create_queue("test-2")
      queues.list.should eq [ queue1, queue2 ]
    end

    it "can be filtered by prefix" do
      queue1 = create_queue("test-1")
      queue2 = create_queue("test-2")
      queue3 = create_queue("other-3")
      queues.list("QueueNamePrefix" => "test").should eq [ queue1, queue2 ]
    end

  end

  describe "#get" do

    it "finds the queue by name" do
      queue = create_queue("test")
      queues.get("test").should eq queue
    end

    it "cannot get the queue if it doesn't exist" do
      expect {
        queues.get("test")
      }.to raise_error(FakeSQS::NonExistentQueue, "test")
    end

  end

  describe "#reset" do

    it "clears all queues" do
      create_queue("foo")
      create_queue("bar")
      queues.should have(2).queues
      queues.reset
      queues.should have(0).queues
    end

  end

  def create_queue(name, options = {})
    queues.create(name, options)
  end

end
