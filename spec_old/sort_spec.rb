require "remi_spec"

describe "Sorting datasets" do
  before do
    @work = Datalib.new :directory => {:dirname => RemiConfig.work_dirname}

    # Create some random data to be sorted
    Datastep.create @work.have do |ds|
      Variables.define ds do |v|
        v.create :mygrp1
        v.create :mygrp2, :type => "number"
        v.create :mydata1, :type => "number"
        v.create :mydata2, :type => "number"
      end

      for irow in 1..100
        ds[:mygrp1] = ('A'..'D').to_a[rand(4)]
        ds[:mygrp2] = (rand()*100).to_i
        ds[:mydata1] = (rand()*10000).to_i
        ds[:mydata2] = rand()

        ds.write_row
      end
    end
  end

  describe "in-memory sort" do
    before do
      @expected_rows = 0
      @expected_data = 0
      Datastep.read @work.have do |ds|
        @expected_rows += 1
        @expected_data += ds[:mydata1]
      end

      Datastep.sort @work.have, out: @work.sorted, by: [:mygrp1,:mygrp2], in_memory: true
    end

    it "should return a dataset with the right number of records and data" do
      actual_rows = 0
      actual_data = 0
      Datastep.read @work.sorted do |ds|
        actual_rows += 1
        actual_data += ds[:mydata1]
      end
      actual_rows.should eq @expected_rows
      actual_data.should eq @expected_data
    end

    it "should be sorted" do
      Datastep.read @work.sorted do |ds|

        next if ds._N_ == 1
        sorted = ds[:mygrp1] <=> ds.prev(:mygrp1)
        sorted = (sorted != 0) ? sorted : ds[:mygrp2] <=> ds.prev(:mygrp2)

        sorted.should be > -1
      end
    end
  end


  describe "dataset sort" do
    before do
      @expected_rows = 0
      @expected_data = 0
      Datastep.read @work.have do |ds|
        @expected_rows += 1
        @expected_data += ds[:mydata1]
      end

      Datastep.sort @work.have, out: @work.sorted, by: [:mygrp1,:mygrp2], in_memory: false, split_size: 10
    end

    it "should return a dataset with the right number of records and data" do
      actual_rows = 0
      actual_data = 0
      Datastep.read @work.sorted do |ds|
        actual_rows += 1
        actual_data += ds[:mydata1]
      end
      actual_rows.should eq @expected_rows
      actual_data.should eq @expected_data
    end

    it "should be sorted" do
      Datastep.read @work.sorted do |ds|

        next if ds._N_ == 1
        sorted = ds[:mygrp1] <=> ds.prev(:mygrp1)
        sorted = (sorted != 0) ? sorted : ds[:mygrp2] <=> ds.prev(:mygrp2)

        sorted.should be > -1
      end
    end
  end
end
