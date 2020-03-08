import os
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image as img
from keras.preprocessing.image import img_to_array
from keras import backend as k
import numpy as np
import tensorflow as tf
from PIL import Image
from keras.applications.resnet50 import ResNet50,decode_predictions,preprocess_input
from datetime import datetime
import io
from flask import Flask,Blueprint,request,render_template,jsonify
from modules.dataBase import collection as db

import matplotlib.pyplot as plt
import os
import re
import numpy as np
import pandas as pd
from scipy import stats

import gensim
import json

import nltk
from nltk.stem import WordNetLemmatizer
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
from nltk.stem import PorterStemmer

import itertools

import keras

from keras.models import Sequential, Model
from keras.layers import Dense, Dropout, Embedding, LSTM, Input, Activation, GlobalAveragePooling1D, Flatten, Concatenate, Conv1D, MaxPooling1D
from keras.layers.normalization import BatchNormalization
from keras.layers.merge import concatenate
from keras.optimizers import SGD, RMSprop, Adagrad, Adam
from keras.preprocessing.text import one_hot, text_to_word_sequence, Tokenizer
from keras.preprocessing.sequence import pad_sequences

from keras.callbacks import EarlyStopping, ModelCheckpoint
from keras.utils.vis_utils import plot_model

import fnmatch

import warnings

import string
from pathlib import Path
from random import shuffle
from ast import literal_eval
import statistics

warnings.filterwarnings('ignore')

mod = Blueprint('backend',__name__,template_folder='templates',static_folder='./static')
UPLOAD_URL = 'http://localhost:5000/static/'
model = load_model('/media/prahlad/New Volume2/DIAC-WOZ/model_glove_lstm_b.h5')

@mod.route('/')
def home():
    return render_template('index.html')

@mod.route('/predict' ,methods=['POST'])
def predict():  
     if request.method == 'POST':
        # check if the post request has the file part
        if 'file' not in request.files:
           return "someting went wrong 1"
      
        user_file = request.files['file']
        temp = request.files['file']
        if user_file.filename == '':
            return "file name not found ..." 
       
        else:
            path = os.path.join(os.getcwd()+'/modules/static/transcripts/'+user_file.filename)
            user_file.save(path)
        
            user_file.seek(0)
            transcript = str(user_file.read())
            print(transcript)

            # db.addNewImage(
            #     user_file.filename,
            #     classes[0][0][1],
            #     str(classes[0][0][2]),
            #     datetime.now(),
            #     UPLOAD_URL+user_file.filename)

            return test_model(transcript, model)

wordnet_lemmatizer = WordNetLemmatizer()

WINDOWS_SIZE = 10
labels=['none','mild','moderate','moderately severe', 'severe']
num_classes = len(labels)

def text_to_wordlist(text, remove_stopwords=True, stem_words=False):    
    # Clean the text, with the option to remove stopwords and to stem words.
    
    # Convert words to lower case and split them
    text = text.lower().split()

    # Optionally, remove stop words
    if remove_stopwords:
        stops = set(stopwords.words("english"))
        text = [wordnet_lemmatizer.lemmatize(w) for w in text if not w in stops ]
        text = [w for w in text if w != "nan" ]
    else:
        text = [wordnet_lemmatizer.lemmatize(w) for w in text]
        text = [w for w in text if w != "nan" ]
    
    text = " ".join(text)

    # Clean the text
    text = re.sub(r"[^A-Za-z0-9^,!.\/'+-=]", " ", text)
    text = re.sub(r"what's", "what is ", text)
    text = re.sub(r"\'s", " ", text)
    text = re.sub(r"\'ve", " have ", text)
    text = re.sub(r"can't", "cannot ", text)
    text = re.sub(r"n't", " not ", text)
    text = re.sub(r"i'm", "i am ", text)
    text = re.sub(r"\'re", " are ", text)
    text = re.sub(r"\'d", " would ", text)
    text = re.sub(r"\'ll", " will ", text)
    text = re.sub(r",", " ", text)
    text = re.sub(r"\.", " ", text)
    text = re.sub(r"!", " ! ", text)
    text = re.sub(r"\/", " ", text)
    text = re.sub(r"\^", " ^ ", text)
    text = re.sub(r"\+", " + ", text)
    text = re.sub(r"\-", " - ", text)
    text = re.sub(r"\=", " = ", text)
    
    text = re.sub(r"\<", " ", text)
    text = re.sub(r"\>", " ", text)
    
    text = re.sub(r"'", " ", text)
    text = re.sub(r"(\d+)(k)", r"\g<1>000", text)
    text = re.sub(r":", " : ", text)
    text = re.sub(r" e g ", " eg ", text)
    text = re.sub(r" b g ", " bg ", text)
    text = re.sub(r" u s ", " american ", text)
    text = re.sub(r"\0s", "0", text)
    text = re.sub(r" 9 11 ", "911", text)
    text = re.sub(r"e - mail", "email", text)
    text = re.sub(r"j k", "jk", text)
    text = re.sub(r"\s{2,}", " ", text)
    
    # Optionally, shorten words to their stems
    if stem_words:
        text = text.split()
        stemmer = SnowballStemmer('english')
        stemmed_words = [stemmer.stem(word) for word in text]
        text = " ".join(stemmed_words)
    
    # Return a list of words
    return(text)

import nltk
nltk.download('wordnet')
nltk.download('stopwords')

data_path = "/media/prahlad/New Volume2/DIAC-WOZ/transcripts/"
#transcripts_to_dataframe(data_path) 
all_participants = pd.read_csv(data_path + 'all.csv', sep=',')

all_participants.columns =  ['index','personId', 'question', 'answer']
all_participants = all_participants.astype({"index": int, "personId": float, "question": str, "answer": str })

all_participants_mix = all_participants.copy()
all_participants_mix['answer'] = all_participants_mix.apply(lambda row: text_to_wordlist(row.answer).split(), axis=1)

all_participants_mix_stopwords = all_participants.copy()
all_participants_mix_stopwords['answer'] = all_participants_mix_stopwords.apply(lambda row: text_to_wordlist(row.answer, remove_stopwords=False).split(), axis=1)

words = [w for w in all_participants_mix['answer'].tolist()]
words = set(itertools.chain(*words))
vocab_size = len(words)

words_stop = [w for w in all_participants_mix_stopwords['answer'].tolist()]
words_stop = set(itertools.chain(*words_stop))
vocab_size_stop = len(words_stop)

windows_size = WINDOWS_SIZE
tokenizer = Tokenizer(num_words=vocab_size)
tokenizer.fit_on_texts(all_participants_mix['answer'])
tokenizer.fit_on_sequences(all_participants_mix['answer'])

all_participants_mix['t_answer'] = tokenizer.texts_to_sequences(all_participants_mix['answer'])

def test_model(text, model):
    word_list = text_to_wordlist(text)
    list_of_words = word_list.split(" ")
    sequences = tokenizer.texts_to_sequences([word_list])
    word_tokens = sequences[0]
    size = len(word_tokens)
    test_phrases = []
    for i in range(size):
        tokens = word_tokens[i:min(i+windows_size,size)]  
        test_phrases.append(tokens)
    sequences_input = test_phrases
    sequences_input =  pad_sequences(sequences_input, value=0, padding="post", maxlen=windows_size)
    
    predicted_classes = []
    for sequence in sequences_input:
        input_a = np.asarray([sequence])
        pred = model.predict(input_a, batch_size=None, verbose=0, steps=None)
        predicted_classes.append(np.argmax(pred))
        
    predicted_class = statistics.mode(predicted_classes)
    return labels[predicted_class]
            

   




            
           
          


