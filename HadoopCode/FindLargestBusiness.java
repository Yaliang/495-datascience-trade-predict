// export HADOOP_CLASSPATH=/usr/lib/jvm/java-7-openjdk-amd64/lib/tools.jar

import java.io.IOException;
import java.io.DataInput;
import java.io.DataOutput;
import java.util.StringTokenizer;
import java.util.Iterator;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.WritableComparable;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;


public class FindLargestBusiness {
    public static class YearNAICSRow implements WritableComparable<YearNAICSRow> {
        private int year;
        private int naics_code;
        private long employee;
        private String information;

        public void set(int y, int naics_c, long emp, String info) {
            year = y;
            naics_code = naics_c;
            employee = emp;
            information = info;
        }

        public int getYear() {
            return year;
        }

        public int getNaics_code() {
            return naics_code;
        }

        public long getEmployee() {
            return employee;
        }

        public String getInfo() {
            return information;
        }

        public long value() {
            return employee;
        }

        public boolean equals(YearNAICSRow o) {
            int thisHash = this.hashCode();
            int thatHash = o.hashCode();
            return (thisHash==thatHash ? true : false);
        }

        public String toString() {
            return "(" + year + ", " + naics_code + ", " + employee + ", " + information + ")";
        }
           
        public void write(DataOutput out) throws IOException {
            out.writeInt(year);
            out.writeInt(naics_code);
            out.writeLong(employee);
            out.writeUTF(information);
        }
           
        public void readFields(DataInput in) throws IOException {
            year = in.readInt();
            naics_code = in.readInt();
            employee = in.readLong();
            information = in.readUTF();
        }

        public int compareTo(YearNAICSRow o) {
            long thisValue = this.value();
            long thatValue = o.value();
            return (thisValue < thatValue ? -1 : (thisValue==thatValue ? 0 : 1));
        }

        public int hashCode() {
            int result = year;
            return result;
        }

        public static YearNAICSRow read(DataInput in) throws IOException {
            YearNAICSRow w = new YearNAICSRow();
            w.readFields(in);
            return w;
        }
    }

    public static class Map extends Mapper<Object, Text, IntWritable, YearNAICSRow> {
        private IntWritable year = new IntWritable();
        private int naics_code;
        private long employee;
        private YearNAICSRow ync_pair = new YearNAICSRow();
        private String info;

        public void map(Object key, Text value, Context context) throws IOException, InterruptedException {
            String line = value.toString();
            StringTokenizer tokenizer = new StringTokenizer(line, "|");
            if (tokenizer.hasMoreTokens()) {
                year.set(Integer.parseInt(tokenizer.nextToken()));
            }
            if (tokenizer.hasMoreTokens()) {
                naics_code = Integer.parseInt(tokenizer.nextToken());
            }
            if (tokenizer.hasMoreTokens()) {
                employee = Long.parseLong(tokenizer.nextToken());
            }
            if (tokenizer.hasMoreTokens()) {
                info = tokenizer.nextToken();
                ync_pair.set(year.get(), naics_code, employee, info);
                context.write(year, ync_pair);
            }
        }
    }

    public static class Reduce extends Reducer<IntWritable, YearNAICSRow, IntWritable, YearNAICSRow> {
        private Text employee = new Text();
        private YearNAICSRow maxitem = new YearNAICSRow();
        private long maxvalue;
        private long currentValue;
        public void reduce(IntWritable key, Iterable<YearNAICSRow> values, Context context) throws IOException, InterruptedException {
            maxvalue = 0;
            for (YearNAICSRow value: values) {
                currentValue = value.getEmployee();
                if (currentValue > maxvalue) {
                    maxitem.set(value.getYear(), value.getNaics_code(), value.getEmployee(), value.getInfo());
                    maxvalue = currentValue;
                }
            }
            context.write(new IntWritable(key.get()), maxitem);
        }
    }

    public static void main(String[] args) throws Exception {
        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "Find Largest Business");
        job.setJarByClass(FindLargestBusiness.class);

        job.setMapperClass(Map.class);
        job.setReducerClass(Reduce.class);

        job.setMapOutputKeyClass(IntWritable.class);
        job.setMapOutputValueClass(YearNAICSRow.class);
        job.setOutputKeyClass(IntWritable.class);
        job.setOutputValueClass(YearNAICSRow.class);

        FileInputFormat.setInputPaths(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }

}