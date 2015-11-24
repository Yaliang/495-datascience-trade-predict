import csv
import datetime
from sklearn.linear_model import LogisticRegression, LinearRegression
from sklearn.svm import SVR
from numpy import *
from pylab import *
from sklearn.feature_selection import SelectKBest,chi2
import heapq
import itertools
import json


def get_input(URL):
    with open(URL) as f_in:
        data = csv.reader(f_in)
        get_data = list()
        index = 0
        for row in data:
            if index == 0:
                get_data.append(row)
                index += 1
                continue
            temp = list()
            for k in row:
                temp.append(float(k))
            get_data.append(temp)

    feature = list()
    label = list()

    # print "get_data:",get_data
    for k in get_data[1:11]:
        temp = k[1:26]
        temp_label = k[26]
        feature.append(temp)
        label.append(temp_label)

    all_feature = list()
    all_label = list()
    for k in get_data[1:]:
        temp = k[1:26]
        temp_label = k[26]
        all_feature.append(temp)
        all_label.append(temp_label)


    test_f = list()
    test_label = list()
    for k in get_data[11:]:
        test_f.append(k[1:26])
        test_label.append(k[26])

    test_f = asarray(test_f)
    test_label = asarray(test_label)

    feature = asarray(feature)
    label = asarray(label)
    attributes = get_data[0]
    attributes = attributes[1:26]
    return feature, label, test_f, test_label,attributes,all_feature,all_label



def get_square_error(data,prediction):
    add = 0
    for index in range(len(data)):
        # print abs(data[index]-prediction[index])
        add += (abs(data[index]-prediction[index]))/abs(data[index])
        # print "add: ",add
    return add/len(data)


if __name__ == '__main__':
    feature, label, test_f, test_label, attribtues,all_feature,all_label = get_input('totalTable.csv')
    print feature.shape
    print attribtues

    print "begin"
    all_index = list()
    all_value = list()
    square_list = list()
    out_value = list()
    for k in range(1,25):
        all_index.append(k)
        select_top_k_feature = SelectKBest(chi2,k)
        linear = LinearRegression()
        _top = list()

        print select_top_k_feature.fit(feature,label).scores_
        square_list = select_top_k_feature.fit(feature,label).scores_
        for data in (select_top_k_feature.fit(feature,label).scores_):
            _top.append(data)
        index = heapq.nlargest(k,range(len(_top)),key = _top.__getitem__)
        test_feature = list()

        # print "index_list:",index
        for id_index in range(len(list(test_f))):
            temp = list()
            for id in index:
                temp.append(test_f[id_index][id])
            test_feature.append(temp)
        test_feature = asarray(test_feature)

        predict_value = linear.fit(select_top_k_feature.fit(feature,label).fit_transform(feature,label),label).predict(test_feature)
        x_new = select_top_k_feature.fit(feature,label).fit_transform(feature,label)
        origin_value = linear.fit(x_new,label).predict(x_new)
        value = get_square_error(list(test_label),list(predict_value))
        if k == 3:
            out_value = list(origin_value)+list(predict_value)
        # print linear.get_params()
        print value
        all_value.append(value)
    min_error = min(all_value)
    result_num = all_value.index(min_error)
    print all_value

    out_csv = list()
    out_csv.append(out_value)
    out_csv.append(list(label)+list(test_label))
    print out_value
    print list(label)+list(test_label)
    with open("output_value.csv", "wb") as f:
        writer = csv.writer(f)
        writer.writerows(out_csv)

    fig=plt.figure()
    plt.xlabel('year')
    plt.ylabel('import_total')
        # yscale(log)
    # fig.suptitle('Subject '+subject+' cout during different time')
    labels = [str(num) for num in range(1998,2013)]
    plt.plot([num for num in range(1998,2013)],out_csv[0],linewidth = 1,color = 'red',label = 'Predict Value')
    plt.plot([num for num in range(1998,2013)],out_csv[1],linewidth = 1,color = 'blue',label = 'True Value')
    plt.legend(loc = 1)
    plt.show()







    # with open('square.json','wr') as f_out:
    #     f_out.write(json.dumps(all_value))
    # result_output = list()
    # result_output.append(attribtues)
    # result_output.append(list(square_list))
    # print all_index[result_num]

    # print "xiangyu"
    # select_top_k_feature = SelectKBest(chi2,3)
    # linear_all = LinearRegression()
    # _top = list()

    # print select_top_k_feature.fit(all_feature,all_label).scores_
    # square_list = select_top_k_feature.fit(all_feature,all_label).scores_
    # for data in (select_top_k_feature.fit(feature,label).scores_):
    #     _top.append(data)
    # index = heapq.nlargest(3,range(len(_top)),key = _top.__getitem__)
    # test_feature_all = list()
    # for id_index in range(len(list(all_feature))):
    #     temp = list()
    #     for id in index:
    #         temp.append(all_feature[id_index][id])
    #     print temp
    #     test_feature_all.append(temp)
    # test_feature_all = asarray(test_feature_all)
    # x_new = select_top_k_feature.fit(all_feature,all_label).fit_transform(all_feature,all_label)
    # # print x_new
    # print all_label
    # linear_all.fit(x_new,all_label)
    # print test_feature_all
    # predict_value_all = linear_all.predict(test_feature_all)
    # all_value_for = get_square_error(list(all_label),list(predict_value_all))
    # print all_value_for
    # linear_all.predict
    # print predict_value.predict(test_feature)
    # # .predict(test_feature)
    # value = get_square_error(list(all_label),list(predict_value))
    # print value
    # print attribtues
    # print square_list
    # import csv
    # with open("output.csv", "wb") as f:
    #     writer = csv.writer(f)
    #     writer.writerows(result_output)
